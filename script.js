'use strict';

(() => {
  const STORAGE_KEY = 'ocl.ruta.v1';
  const COPY_LABEL = 'Copiar';
  const COPIED_LABEL = 'Copiado';
  const FAILED_LABEL = 'Error';
  const RESET_MS = 1500;

  const readState = () => {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {};
    } catch (_) {
      return {};
    }
  };

  const writeState = (state) => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (_) {
      /* storage blocked (private mode, policy): progress is simply not persisted */
    }
  };

  const initChecklist = () => {
    const boxes = document.querySelectorAll('.checklist input[type="checkbox"]');
    const saved = readState();
    boxes.forEach((box) => {
      box.checked = Boolean(saved[box.dataset.step]);
      box.addEventListener('change', () => {
        writeState({ ...readState(), [box.dataset.step]: box.checked });
      });
    });
  };

  const makeCopyButton = (pre, code) => {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'copy-btn';
    button.textContent = COPY_LABEL;
    button.setAttribute('aria-label', 'Copiar al portapapeles');
    button.addEventListener('click', () => {
      navigator.clipboard
        .writeText(code.textContent)
        .then(() => {
          button.textContent = COPIED_LABEL;
        })
        .catch(() => {
          button.textContent = FAILED_LABEL;
        })
        .finally(() => {
          setTimeout(() => {
            button.textContent = COPY_LABEL;
          }, RESET_MS);
        });
    });
    pre.classList.add('has-copy');
    pre.appendChild(button);
  };

  const initCopyButtons = () => {
    if (!navigator.clipboard) {
      return;
    }
    document.querySelectorAll('pre > code').forEach((code) => {
      makeCopyButton(code.parentElement, code);
    });
  };

  initChecklist();
  initCopyButtons();
})();
