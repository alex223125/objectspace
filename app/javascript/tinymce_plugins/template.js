/*
 * Free replacement for the old TinyMCE "template" plugin.
 *
 * TinyMCE 7+ removed the original template plugin.
 * This custom plugin provides basic template selection/insertion
 * without requiring TinyMCE Premium.
 *
 * Usage:
 *
 *   import './tinymce_plugins/template';
 *
 *   tinymce.init({
 *     plugins: 'template',
 *     toolbar: 'template'
 *   });
 *
 * Templates can be supplied through the TinyMCE init configuration:
 *
 *   templates: [
 *     {
 *       title: 'Introduction',
 *       description: 'Basic introduction',
 *       content: '<h2>Introduction</h2><p>Write your introduction here.</p>'
 *     }
 *   ]
 *
 * Or:
 *
 *   template_items: [...]
 *
 * Both "templates" and "template_items" are supported.
 */

(function () {
    'use strict';

    if (typeof tinymce === 'undefined') {
        console.error(
            '[template plugin] TinyMCE must be loaded before the template plugin.'
        );
        return;
    }

    /*
     * Register under the exact old plugin name.
     *
     * This allows existing configurations such as:
     *
     *   plugins: 'template'
     *
     * to continue working.
     */
    tinymce.PluginManager.add('template', (editor) => {
        /*
         * Escape HTML for displaying template information
         * inside the TinyMCE dialog.
         */
        const escapeHtml = (value) => {
            const div = document.createElement('div');
            div.textContent = String(value ?? '');
            return div.innerHTML;
        };

        /*
         * Get templates from the editor configuration.
         *
         * Supported:
         *
         *   templates: [...]
         *
         * and:
         *
         *   template_items: [...]
         */
        const getTemplates = () => {
            const templates =
                editor.options.get('templates') ||
                editor.options.get('template_items') ||
                [];

            /*
             * Allow a function to dynamically provide templates.
             */
            if (typeof templates === 'function') {
                const result = templates(editor);

                return Array.isArray(result) ? result : [];
            }

            return Array.isArray(templates) ? templates : [];
        };

        /*
         * Normalize template objects so different formats can be used.
         *
         * Supported formats:
         *
         * {
         *   title: 'My template',
         *   description: 'Description',
         *   content: '<p>Hello</p>'
         * }
         *
         * {
         *   title: 'My template',
         *   html: '<p>Hello</p>'
         * }
         *
         * {
         *   name: 'My template',
         *   content: '<p>Hello</p>'
         * }
         */
        const normalizeTemplate = (template, index) => {
            if (typeof template === 'string') {
                return {
                    id: `template-${index}`,
                    title: `Template ${index + 1}`,
                    description: '',
                    content: template,
                };
            }

            if (!template || typeof template !== 'object') {
                return null;
            }

            return {
                id:
                    template.id ||
                    template.key ||
                    template.name ||
                    `template-${index}`,

                title:
                    template.title ||
                    template.name ||
                    `Template ${index + 1}`,

                description:
                    template.description ||
                    template.desc ||
                    '',

                content:
                    template.content ??
                    template.html ??
                    template.body ??
                    '',
            };
        };

        /*
         * Return normalized templates.
         */
        const getNormalizedTemplates = () => {
            return getTemplates()
                .map(normalizeTemplate)
                .filter((template) => template && template.content !== '');
        };

        /*
         * Insert the selected template into TinyMCE.
         *
         * We use insertContent(), which lets TinyMCE process
         * the HTML according to the editor configuration.
         */
        const insertTemplate = (template) => {
            if (!template) {
                return;
            }

            editor.focus();

            editor.undoManager.transact(() => {
                editor.insertContent(template.content);
            });

            /*
             * Notify TinyMCE that the editor content changed.
             */
            editor.nodeChanged();
        };

        /*
         * Open the template selector dialog.
         */
        const openTemplateDialog = () => {
            const templates = getNormalizedTemplates();

            if (templates.length === 0) {
                editor.windowManager.alert(
                    'No templates are configured for this editor.'
                );

                return;
            }

            /*
             * Create options for TinyMCE's select component.
             */
            const options = templates.map((template) => ({
                text:
                    template.description.length > 0
                        ? `${template.title} — ${template.description}`
                        : template.title,

                value: template.id,
            }));

            editor.windowManager.open({
                title: 'Insert Template',

                size: 'normal',

                body: {
                    type: 'panel',

                    items: [
                        {
                            type: 'selectbox',

                            name: 'template',

                            label: 'Template',

                            items: options,
                        },
                    ],
                },

                buttons: [
                    {
                        type: 'cancel',
                        text: 'Cancel',
                    },

                    {
                        type: 'submit',
                        text: 'Insert',
                        buttonType: 'primary',
                    },
                ],

                initialData: {
                    template: templates[0].id,
                },

                onSubmit: (api) => {
                    const data = api.getData();

                    const selectedTemplate = templates.find(
                        (template) => template.id === data.template
                    );

                    if (selectedTemplate) {
                        insertTemplate(selectedTemplate);
                    }

                    api.close();
                },
            });
        };

        /*
         * TinyMCE command.
         *
         * This allows:
         *
         *   editor.execCommand('mceTemplate');
         */
        editor.addCommand('mceTemplate', () => {
            openTemplateDialog();
        });

        /*
         * Toolbar button.
         *
         * Existing configurations using:
         *
         *   toolbar: 'template'
         *
         * will work.
         */
        editor.ui.registry.addButton('template', {
            text: 'Templates',

            tooltip: 'Insert Template',

            onAction: () => {
                openTemplateDialog();
            },
        });

        /*
         * Menu item.
         *
         * This can be used in menus with:
         *
         *   menu: {
         *     insert: {
         *       title: 'Insert',
         *       items: 'template'
         *     }
         *   }
         */
        editor.ui.registry.addMenuItem('template', {
            text: 'Insert Template',

            onAction: () => {
                openTemplateDialog();
            },
        });

        /*
         * Optional keyboard shortcut.
         *
         * Alt+Shift+T opens the template dialog.
         */
        editor.addShortcut(
            'alt+shift+t',
            'Insert template',
            'mceTemplate'
        );

        /*
         * Return plugin metadata.
         */
        return {
            getMetadata: () => ({
                name: 'Free Template Plugin',
                url: '',
            }),
        };
    });
})();
