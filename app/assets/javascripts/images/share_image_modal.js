import setFlashMessage from './set_flash_message'

class ShareImageModal {
  constructor(modalSelector) {
    this.$modal = $(modalSelector);
    this.$shareForm = this.$modal.find('form');
    this.cleanFormHTML = this.$shareForm.html();
  }

  setupModal({sharePath, imageUrl}) {
    this.$shareForm.attr('action', sharePath);
    this.$shareForm.find('img').attr('src', imageUrl);
  }

  clearForm() {
    this.$shareForm.html(this.cleanFormHTML);
  }

  attachEventHandlers() {
    this.$modal.on('show.bs.modal', event => {
      const modalTrigger = event.relatedTarget;
      this.setupModal(modalTrigger.dataset);
    });

    this.$modal.on('hide.bs.modal', event => {
      this.clearForm();
    });

    this.$modal.on('ajax:success', (e, xhr) => {
      this.$modal.modal('hide');
      setFlashMessage('success', 'Email successfully sent!');
      require('./animation').scrollToTop(500);
    });

    this.$modal.on('ajax:error', (e, xhr) => {
      if (xhr.status === 422) {
        this.$shareForm.html(xhr.responseJSON.share_form_html);
      }
      else if (xhr.status === 404) {
        this.$modal.modal('hide');
        window.location.replace('/');
      }
      else {
        alert('Something went terribly wrong. Please try again.');
      }
    });
  }
}

export default ShareImageModal;
