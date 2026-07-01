// app/javascript/src/tinymce_plugins/template/plugin.js
(function () {
    'use strict';
    var global = tinymce.util.Tools.resolve('tinymce.PluginManager');
    global.add('template', function (editor) {
        editor.ui.registry.addButton('template', {
            icon: 'template',
            tooltip: 'Insert template',
            onAction: function () {
                editor.execCommand('mceTemplate');
            }
        });
        return {
            getMetadata: function () {
                return { name: 'Template Plugin' };
            }
        };
    });
}());
