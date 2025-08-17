(function () {
  // デプロイ時刻を表示
  const el = document.getElementById('deployedAt');
  if (el) {
    const now = new Date().toISOString().replace('T',' ').replace('Z',' UTC');
    el.textContent = `Deployed at: ${now}`;
  }
  // 現在のオリジンをリンクに表示
  const originEl = document.getElementById('originUrl');
  if (originEl) originEl.href = location.origin + '/';
})();
