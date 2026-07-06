import { Application } from "@hotwired/stimulus"
import Clipboard from 'stimulus-clipboard'

const application = Application.start()
application.register('clipboard', Clipboard)


// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import Rails from '@rails/ujs';
window.Rails = Rails;
Rails.start();

// import 'cropperjs/src/index.js'
import 'cropperjs';
