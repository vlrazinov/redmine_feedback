// redmine_feedback/assets/javascripts/feedback.js

document.addEventListener('DOMContentLoaded', function() {
  // Добавляем обработчик для ссылок на форму обратной связи
  var feedbackLinks = document.querySelectorAll('.feedback-link');
  feedbackLinks.forEach(function(link) {
    link.addEventListener('click', function(e) {
      // Открываем в новой вкладке
      // Стандартное поведение уже target="_blank"
    });
  });
});
