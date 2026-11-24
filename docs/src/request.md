# Замовити

Хочеш новий альбом, фільм чи серіал, або щось не працює? Напиши тут -
запит одразу прийде адміністратору на телефон. Підписуватися не треба:
видно, з чийого пристрою його надіслано.

<form id="request-form">
<p><label>Що саме<br>
<select id="request-topic">
<option value="music">Музика</option>
<option value="films">Фільми та серіали</option>
<option value="other">Інше</option>
</select></label></p>
<p><label>Запит<br>
<textarea id="request-text" rows="5" maxlength="1000" required placeholder="Наприклад: Radiohead - OK Computer"></textarea></label></p>
<p><button type="submit">Надіслати</button> <span id="request-status" role="status"></span></p>
</form>

<style>
#request-form select, #request-form textarea, #request-form button {
	font: inherit;
	color: var(--fg);
	background: var(--theme-popup-bg);
	border: 1px solid var(--theme-popup-border);
	border-radius: 4px;
	padding: 0.4em 0.6em;
}
#request-form textarea { width: 100%; box-sizing: border-box; }
#request-form button { cursor: pointer; }
</style>

<script>
(() => {
	const form = document.getElementById('request-form');
	const topic = document.getElementById('request-topic');
	const text = document.getElementById('request-text');
	const status = document.getElementById('request-status');
	const button = form.querySelector('button');
	form.addEventListener('submit', async (event) => {
		event.preventDefault();
		const body = text.value.trim();
		if (!body) return;
		button.disabled = true;
		status.textContent = 'Надсилаю...';
		try {
			const res = await fetch('/request/' + topic.value, { method: 'POST', body });
			if (!res.ok) throw new Error(res.status);
			text.value = '';
			status.textContent = 'Надіслано, дякую!';
		} catch (err) {
			status.textContent = 'Не вдалося надіслати (' + err.message + '). Спробуй пізніше.';
		} finally {
			button.disabled = false;
		}
	});
})();
</script>

## Як писати

- **Музика:** виконавець і альбом (або "вся дискографія").
- **Фільми та серіали:** назва і рік, для серіалу - які сезони; якщо
  важлива озвучка чи субтитри - теж напиши.
- **Інше:** акаунт у сервісі, щось зламалося, ідея нового сервісу.

Коли замовлене з'явиться - про це буде в [Новинах](news.md).
