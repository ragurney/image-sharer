import setFlashMessage from './set_flash_message'

class LikeButton {
  constructor(element) {
    this.element = element;
    this.attachEventHandlers();

    const tokenMetaTag = document.querySelector('meta[name="csrf-token"]');
    this.csrfToken = tokenMetaTag && tokenMetaTag.content;
  }

  updateLikeBtn({likeCount}) {
    const likeCountField = this.element.getElementsByClassName('js-like-count')[0];

    this.element.blur();
    likeCountField.innerHTML = likeCount;
    this.element.classList.toggle('image-card__liked')
  }

  attachEventHandlers() {
    this.element.addEventListener('click', e => {
      e.preventDefault();
      fetch( this.element.href, {
        credentials: 'include',
        method: 'post',
        headers: {
          'X-CSRF-Token': this.csrfToken,
          "Accept": "application/json"
        }
      })
        .then(response => {
          if (response.ok) {
            return response.json();
          }
          else if(response.status == 404) {
            window.location.replace('/');
          }
          else if(response.status == 401) {
            setFlashMessage('danger', 'You must log in to like images!');
          }
          else {
            alert("You've encountered an unsupported error. Please try again.");
          }
        })
        .then( data => {
          (data != null) && this.updateLikeBtn(data)
        })
        .catch( e => alert('Something went terribly wrong. Please try again.'));
    });
  }
}

export default LikeButton;
