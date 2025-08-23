# Azure Infrastructure Deployment Script for Windows
# This script provides the same functionality as the Makefile for Windows users

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("up", "down", "deploy-app", "url", "help")]
    [string]$Action
)

$ENV_DIR = "envs/azure/azure-b1s-mvp"
$DOCKER_RUN = "docker run --rm -it --env-file .env -v ${PWD}:/workspace -w /workspace hashicorp/terraform:1.9.5"

function Show-Help {
    Write-Host "Available commands:" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 One-click commands:" -ForegroundColor Yellow
    Write-Host "  .\azure-deploy.ps1 up        - Deploy Azure infrastructure"
    Write-Host "  .\azure-deploy.ps1 down      - Destroy Azure infrastructure (with confirmation)"
    Write-Host "  .\azure-deploy.ps1 deploy-app - Deploy application"
    Write-Host "  .\azure-deploy.ps1 url       - Get Azure website URL"
    Write-Host ""
    Write-Host "⚠️  WARNING: 'down' will destroy ALL resources!" -ForegroundColor Red
}

function Initialize-LocalConfig {
    Write-Host "🔧 Initializing Terraform for local development..." -ForegroundColor Blue
    Write-Host "📁 Using local configuration..."
    
    # main.tfが存在し、main.tf.remoteが存在しない場合はバックアップ
    if ((Test-Path "$ENV_DIR/main.tf") -and (-not (Test-Path "$ENV_DIR/main.tf.remote"))) {
        Copy-Item "$ENV_DIR/main.tf" "$ENV_DIR/main.tf.remote"
        Write-Host "✅ Backed up remote configuration" -ForegroundColor Green
    }
    
    # main.local.tfが存在する場合は、main.tfを置き換えてmain.local.tfを一時的に隠す
    if (Test-Path "$ENV_DIR/main.local.tf") {
        # main.local.tfを一時的にリネーム（Terraformが読み込まないように）
        if (Test-Path "$ENV_DIR/main.local.tf") {
            Move-Item "$ENV_DIR/main.local.tf" "$ENV_DIR/main.local.tf.bak" -Force
        }
        
        if (Test-Path "$ENV_DIR/main.tf") {
            Remove-Item "$ENV_DIR/main.tf" -Force
        }
        Copy-Item "$ENV_DIR/main.local.tf.bak" "$ENV_DIR/main.tf"
        Write-Host "✅ Switched to local configuration" -ForegroundColor Green
    } else {
        Write-Host "❌ main.local.tf not found" -ForegroundColor Red
        return
    }
    
    Write-Host "🔧 Initializing Terraform..." -ForegroundColor Blue
    Invoke-Expression "$DOCKER_RUN -chdir=$ENV_DIR init -reconfigure"
}

function Deploy-Infrastructure {
    Write-Host "🚀 Setting up Azure infrastructure..." -ForegroundColor Green
    Write-Host "📋 Using local state for development..."
    
    Initialize-LocalConfig
    
    Write-Host "🚀 Applying Terraform configuration..." -ForegroundColor Blue
    Invoke-Expression "$DOCKER_RUN -chdir=$ENV_DIR apply -auto-approve"
}

function Destroy-Infrastructure {
    Write-Host "🗑️ Destroying Azure infrastructure..." -ForegroundColor Red
    Write-Host "⚠️  WARNING: This will destroy ALL Azure resources!" -ForegroundColor Red
    Write-Host "Press Ctrl+C within 5 seconds to cancel..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Initialize-LocalConfig
    
    Write-Host "🗑️ Planning destruction..." -ForegroundColor Yellow
    Invoke-Expression "$DOCKER_RUN -chdir=$ENV_DIR plan -destroy"
    
    Write-Host ""
    Write-Host "⚠️  FINAL CONFIRMATION REQUIRED ⚠️" -ForegroundColor Red
    Write-Host "This will permanently delete all Azure resources!"
    $confirm = Read-Host "Type 'yes' to confirm destruction"
    
    if ($confirm -eq "yes") {
        Write-Host "🗑️ Destroying resources..." -ForegroundColor Red
        Invoke-Expression "$DOCKER_RUN -chdir=$ENV_DIR destroy -auto-approve"
        
        # Cleanup local configuration
        if (Test-Path "$ENV_DIR/main.tf.remote") {
            Copy-Item "$ENV_DIR/main.tf.remote" "$ENV_DIR/main.tf" -Force
            Write-Host "✅ Configuration restored to remote backend" -ForegroundColor Green
        }
        # main.local.tf.bakを元に戻す
        if (Test-Path "$ENV_DIR/main.local.tf.bak") {
            Move-Item "$ENV_DIR/main.local.tf.bak" "$ENV_DIR/main.local.tf" -Force
            Write-Host "✅ Local template restored" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Destruction cancelled" -ForegroundColor Yellow
    }
}

function Deploy-App {
    Write-Host "📦 Deploying application..." -ForegroundColor Blue
    
    if (Test-Path "app") {
        try {
            $result = docker run --rm --env-file .env -v "${PWD}:/workspace" -w /workspace hashicorp/terraform:1.9.5 -chdir=$ENV_DIR output -raw storage_account_name 2>$null
            if ($LASTEXITCODE -eq 0 -and $result) {
                $storageAccount = $result.Trim()
                Write-Host "🚀 Uploading files to $storageAccount..." -ForegroundColor Blue
                $azureCmd = "docker run --rm -it --env-file .env -v `"${PWD}:/workspace`" -w /workspace mcr.microsoft.com/azure-cli:latest sh -c 'az login --service-principal -u `$ARM_CLIENT_ID -p `$ARM_CLIENT_SECRET --tenant `$ARM_TENANT_ID > /dev/null && az storage blob upload-batch --account-name $storageAccount --source app --destination `"\`$web`" --auth-mode key --overwrite'"
                Invoke-Expression $azureCmd
                Write-Host "✅ Application deployed successfully!" -ForegroundColor Green
            } else {
                Write-Host "❌ Storage account not found. Run '.\azure-deploy.ps1 up' first." -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ Error getting storage account: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ No app directory found" -ForegroundColor Red
    }
}

function Get-WebsiteUrl {
    Write-Host "🌐 Getting Azure website URL..." -ForegroundColor Blue
    try {
        $result = docker run --rm --env-file .env -v "${PWD}:/workspace" -w /workspace hashicorp/terraform:1.9.5 -chdir=$ENV_DIR output -raw static_website_url 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            $url = $result.Trim()
            Write-Host "🌐 Website URL: $url" -ForegroundColor Green
            Write-Host "🚀 Opening website in browser..." -ForegroundColor Blue
            Start-Process $url
        } else {
            Write-Host "No URL output available. Run '.\azure-deploy.ps1 up' first." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "No URL output available. Run '.\azure-deploy.ps1 up' first." -ForegroundColor Yellow
    }
}

# Main execution
switch ($Action) {
    "up" { Deploy-Infrastructure }
    "down" { Destroy-Infrastructure }
    "deploy-app" { Deploy-App }
    "url" { Get-WebsiteUrl }
    "help" { Show-Help }
}