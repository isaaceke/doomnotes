chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'exportXBookmarks') {
    exportXBookmarks()
      .then((data) => {
        downloadJSON(data, 'x-bookmarks.json');
        sendResponse({ count: data.length });
      })
      .catch((error) => {
        sendResponse({ error: error.message });
      });
    return true;
  }

  if (request.action === 'exportInstagramSaved') {
    exportInstagramSaved()
      .then((data) => {
        downloadJSON(data, 'instagram-saved.json');
        sendResponse({ count: data.length });
      })
      .catch((error) => {
        sendResponse({ error: error.message });
      });
    return true;
  }

  if (request.action === 'exportYouTubeWatchLater') {
    exportYouTubeWatchLater()
      .then((data) => {
        downloadJSON(data, 'youtube-watch-later.json');
        sendResponse({ count: data.length });
      })
      .catch((error) => {
        sendResponse({ error: error.message });
      });
    return true;
  }
});

async function exportXBookmarks() {
  const bookmarks = [];
  let cursor = null;

  while (true) {
    const url = 'https://api.x.com/2/users/me/bookmarks' + (cursor ? `?cursor=${cursor}` : '');
    const response = await fetch(url, {
      headers: {
        'Authorization': 'Bearer ' + await getAuthToken(),
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) throw new Error('X API error: ' + response.status);

    const data = await response.json();
    const items = data.data || [];

    bookmarks.push(
      ...items.map((item) => ({
        source: 'x',
        type: 'postUrl',
        url: 'https://x.com/i/status/' + item.id,
        title: item.text?.slice(0, 100) || '',
        capturedAt: new Date().toISOString(),
      }))
    );

    if (!data.meta?.next_cursor) break;
    cursor = data.meta.next_cursor;

    if (bookmarks.length >= 2000) break;
  }

  return bookmarks;
}

async function exportInstagramSaved() {
  const saved = [];
  const response = await fetch('https://www.instagram.com/api/v1/feed/saved/', {
    headers: {
      'x-ig-app-id': '936619743392459',
      'x-ig-www-claim': await getIGClaim(),
    },
  });

  if (!response.ok) throw new Error('Instagram error: ' + response.status);
  const data = await response.json();
  const items = data.items || [];

  saved.push(
    ...items.map((item) => ({
      source: 'instagram',
      type: item.media_type === 2 ? 'videoUrl' : 'postUrl',
      url: 'https://www.instagram.com/p/' + item.code + '/',
      title: (item.caption?.text || '').slice(0, 100),
      capturedAt: new Date().toISOString(),
    }))
  );

  return saved;
}

async function exportYouTubeWatchLater() {
  const videos = [];
  const response = await fetch('https://www.youtube.com/feed/watch_later');
  if (!response.ok) throw new Error('YouTube error: ' + response.status);

  const html = await response.text();
  const videoIdRegex = /\/watch\?v=([a-zA-Z0-9_-]{11})/g;
  let match;

  const seen = new Set();
  while ((match = videoIdRegex.exec(html)) !== null) {
    const id = match[1];
    if (seen.has(id)) continue;
    seen.add(id);

    videos.push({
      source: 'youtube',
      type: 'videoUrl',
      url: 'https://www.youtube.com/watch?v=' + id,
      title: '',
      capturedAt: new Date().toISOString(),
    });

    if (videos.length >= 500) break;
  }

  return videos;
}

function downloadJSON(data, filename) {
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

async function getAuthToken() {
  const result = await chrome.storage.local.get('xAuthToken');
  return result.xAuthToken || '';
}

async function getIGClaim() {
  const result = await chrome.storage.local.get('igClaim');
  return result.igClaim || '';
}