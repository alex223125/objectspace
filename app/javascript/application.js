// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

//= require jquery
//= require jquery_ujs

//= require rails-ujs

import "./libs/import_jquery.js"

import Prism from "./libs/prism"

import 'cocoon-js'

import "flowbite/dist/flowbite.turbo.js";
import "flowbite"


// components
import "./components/saving_method_tabs_state.js"
import "./components/saving_algorithm_tabs_state.js"

import "./components/algorithms/scroll_to_top_step_button"
import "./components/algorithms/scroll_to_top_substep_button"


import Alpine from 'alpinejs'
window.Alpine = Alpine
$(() => {
    Alpine.start();
});



// REPLACE WITH THIS Standard Clean Module Export:
import 'cropperjs';