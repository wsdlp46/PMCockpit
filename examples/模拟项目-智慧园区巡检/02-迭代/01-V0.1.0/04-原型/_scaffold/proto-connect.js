const sidebarStyle = document.createElement('style');
sidebarStyle.textContent = '.demo-sidebar{position:fixed;top:0;right:0;width:300px;height:100vh;padding:28px 24px;background:#102a43;color:#fff;line-height:1.7}.demo-sidebar h2{margin-top:0;font-size:18px}.demo-sidebar ol{padding-left:20px}';
document.head.appendChild(sidebarStyle);

const rows = [...document.querySelectorAll('#task-table tr')];
const count = document.querySelector('#task-count');
const empty = document.querySelector('#empty-state');
function applyFilter(status) {
  const visibleRows = rows.filter((row) => status === 'all' || row.dataset.status === status);
  rows.forEach((row) => { row.hidden = !visibleRows.includes(row); });
  count.textContent = `${visibleRows.length} 项任务`;
  empty.hidden = visibleRows.length !== 0;
}
document.querySelectorAll('.filter').forEach((button) => button.addEventListener('click', () => {
  document.querySelectorAll('.filter').forEach((item) => item.classList.remove('active'));
  button.classList.add('active');
  applyFilter(button.dataset.status);
}));
document.querySelectorAll('.complete').forEach((button) => button.addEventListener('click', () => {
  const row = button.closest('tr');
  row.dataset.status = 'done';
  row.querySelector('.tag').className = 'tag done';
  row.querySelector('.tag').textContent = '已完成';
  button.parentElement.textContent = '—';
  applyFilter(document.querySelector('.filter.active').dataset.status);
}));
