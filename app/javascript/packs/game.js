import Sortable from 'sortablejs';

// const input = document.getElementById("guess-input");

const letterCards = document.querySelectorAll(".letter-card-lg");

const selectLetter = (event) => {
  if (!event.currentTarget.classList.contains("inactive")) {
    const preview = document.getElementById("guess-preview");
    const letter = event.currentTarget.innerText;
    event.currentTarget.classList.add("inactive");
    preview.insertAdjacentHTML("beforeEnd", `<li class="letter-card letter-card-sm list-inline-item border active">${letter}</li>`);
    preview.querySelector("li:last-child").addEventListener("click", removeLetter);
  };
};

const removeLetter = (event) => {
  if (event.currentTarget.classList.contains("active")) {
    const previewLetters = document.querySelectorAll(".letter-card-sm");
    const letter = event.currentTarget.innerText;
    const index = Array.from(previewLetters).indexOf(event.currentTarget);
    document.querySelector(`li.inactive[data-target='${letter}']`).classList.remove("inactive");
    event.currentTarget.remove();
  };
};

const previewToGuess = () => {
  const previewLetters = document.querySelectorAll(".letter-card-sm");
  let tmp = "";
  previewLetters.forEach((el) => { tmp += el.innerText });
  document.getElementById("guess-input").value = tmp;
};

const initPreview = () => {
  letterCards.forEach((letterCard) => {
    letterCard.addEventListener("click", selectLetter);
  });
  document.getElementById("form-guess").addEventListener("submit", (event) => {
    previewToGuess();
  });
};

initPreview();

const preview = document.getElementById('guess-preview');
const sortable = Sortable.create(preview, {
  animation: 150,
  ghostClass: "sortable-ghost"
});

export { initPreview };
