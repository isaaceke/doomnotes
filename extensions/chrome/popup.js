document.getElementById('exportX').addEventListener('click', async () => {
  const statusEl = document.getElementById('statusX');
  statusEl.textContent = 'Starting export...';

  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (!tab || !tab.url.includes('x.com') && !tab.url.includes('twitter.com')) {
      statusEl.textContent = 'Open X/Twitter bookmarks page first.';
      return;
    }

    chrome.tabs.sendMessage(tab.id, { action: 'exportXBookmarks' }, (response) => {
      if (!response || response.error) {
        statusEl.textContent = 'Export failed: ' + (response?.error || 'Unknown error');
        return;
      }
      statusEl.textContent = 'Exported ' + response.count + ' bookmarks.';
    });
  } catch (error) {
    statusEl.textContent = 'Export failed: ' + error.message;
  }
});

document.getElementById('exportInstagram').addEventListener('click', async () => {
  const statusEl = document.getElementById('statusInstagram');
  statusEl.textContent = 'Starting export...';

  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (!tab || !tab.url.includes('instagram.com')) {
      statusEl.textContent = 'Open Instagram Saved page first.';
      return;
    }

    chrome.tabs.sendMessage(tab.id, { action: 'exportInstagramSaved' }, (response) => {
      if (!response || response.error) {
        statusEl.textContent = 'Export failed: ' + (response?.error || 'Unknown error');
        return;
      }
      statusEl.textContent = 'Exported ' + response.count + ' saved posts.';
    });
  } catch (error) {
    statusEl.textContent = 'Export failed: ' + error.message;
  }
});

document.getElementById('exportYouTube').addEventListener('click', async () => {
  const statusEl = document.getElementById('statusYouTube');
  statusEl.textContent = 'Starting export...';

  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (!tab || !tab.url.includes('youtube.com')) {
      statusEl.textContent = 'Open YouTube Watch Later page first.';
      return;
    }

    chrome.tabs.sendMessage(tab.id, { action: 'exportYouTubeWatchLater' }, (response) => {
      if (!response || response.error) {
        statusEl.textContent = 'Export failed: ' + (response?.error || 'Unknown error');
        return;
      }
      statusEl.textContent = 'Exported ' + response.count + ' videos.';
    });
  } catch (error) {
    statusEl.textContent = 'Export failed: ' + error.message;
  }
});