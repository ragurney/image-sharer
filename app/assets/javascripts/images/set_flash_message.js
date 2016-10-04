export default function setFlashMessage(type, msg) {
    $('#flash_messages').html(`<div class="alert alert-${type}">${msg}</div>`);
}
