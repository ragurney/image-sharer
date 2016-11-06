import LikeButton from './like_button';

const elements = document.getElementsByClassName('js-like-btn');

[].forEach.call(elements, element => new LikeButton(element));
