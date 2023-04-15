import { Controller } from "@hotwired/stimulus";

// Import TinyMCE
import tinymce from 'tinymce/tinymce'

// Import icons
import 'tinymce/icons/default/icons'

// Import theme
import 'tinymce/themes/silver/theme';

// Import skin
import 'tinymce/skins/ui/oxide/skin.min.css';

// Import plugins

import 'tinymce/plugins/advlist';
import 'tinymce/plugins/anchor';
import 'tinymce/plugins/autolink';
import 'tinymce/plugins/autoresize';
import 'tinymce/plugins/autosave';
// import 'tinymce/plugins/bbcode';
import 'tinymce/plugins/charmap';
import 'tinymce/plugins/code';
import 'tinymce/plugins/codesample';
// import 'tinymce/plugins/colorpicker';
// import 'tinymce/plugins/contextmenu';
import 'tinymce/plugins/directionality';
import 'tinymce/plugins/emoticons';
// import 'tinymce/plugins/fullpage';
import 'tinymce/plugins/fullscreen';
import 'tinymce/plugins/help';
// import 'tinymce/plugins/hr';
import 'tinymce/plugins/image';
// import 'tinymce/plugins/imagetools';
import 'tinymce/plugins/insertdatetime';
// import 'tinymce/plugins/legacyoutput';
import 'tinymce/plugins/link';
import 'tinymce/plugins/lists';
import 'tinymce/plugins/media';
import 'tinymce/plugins/nonbreaking';
// import 'tinymce/plugins/noneditable';
import 'tinymce/plugins/pagebreak';
// import 'tinymce/plugins/paste';
import 'tinymce/plugins/preview';
// import 'tinymce/plugins/print';
import 'tinymce/plugins/quickbars';
import 'tinymce/plugins/save';
import 'tinymce/plugins/searchreplace';
// import 'tinymce/plugins/spellchecker';
// import 'tinymce/plugins/tabfocus';
import 'tinymce/plugins/table';
import 'tinymce/plugins/template';
// import 'tinymce/plugins/textcolor';
// import 'tinymce/plugins/textpattern';
// import 'tinymce/plugins/toc';
import 'tinymce/plugins/visualblocks';
import 'tinymce/plugins/visualchars';
import 'tinymce/plugins/wordcount';

export default class extends Controller {
    static targets = ['field']

    initialize () {
        this.defaults = {
            toolbar: 'undo redo | styles | formatselect | bold italic backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | removeformat | help | codesample',
            mobile: {
                toolbar: [
                    'undo redo | styles | formatselect | bold italic backcolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | removeformat | help | codesample'
                ]
            },
            placeholder: "placeholder placeholder placeholder",
            plugins: 'advlist, autolink, lists, link, image, charmap, print, preview, anchor, searchreplace, visualblocks, code, fullscreen, insertdatetime, media, table, paste, code, help, wordcount, codesample',
            codesample_languages: [
                {text:'HTML/XML',value:'markup'},
                {text:"XML",value:"xml"},
                {text:"HTML",value:"html"},
                {text:"mathml",value:"mathml"},
                {text:"SVG",value:"svg"},
                {text:"CSS",value:"css"},
                {text:"Clike",value:"clike"},
                {text:"Javascript",value:"javascript"},
                {text:"ActionScript",value:"actionscript"},
                {text:"apacheconf",value:"apacheconf"},
                {text:"apl",value:"apl"},
                {text:"applescript",value:"applescript"},
                {text:"asciidoc",value:"asciidoc"},
                {text:"aspnet",value:"aspnet"},
                {text:"autoit",value:"autoit"},
                {text:"autohotkey",value:"autohotkey"},
                {text:"bash",value:"bash"},
                {text:"basic",value:"basic"},
                {text:"batch",value:"batch"},
                {text:"c",value:"c"},
                {text:"brainfuck",value:"brainfuck"},
                {text:"bro",value:"bro"},
                {text:"bison",value:"bison"},
                {text:"C#",value:"csharp"},
                {text:"C++",value:"cpp"},
                {text:"CoffeeScript",value:"coffeescript"},
                {text:"ruby",value:"ruby"},
                {text:"d",value:"d"},
                {text:"dart",value:"dart"},
                {text:"diff",value:"diff"},
                {text:"docker",value:"docker"},
                {text:"eiffel",value:"eiffel"},
                {text:"elixir",value:"elixir"},
                {text:"erlang",value:"erlang"},
                {text:"fsharp",value:"fsharp"},
                {text:"fortran",value:"fortran"},
                {text:"git",value:"git"},
                {text:"glsl",value:"glsl"},
                {text:"go",value:"go"},
                {text:"groovy",value:"groovy"},
                {text:"haml",value:"haml"},
                {text:"handlebars",value:"handlebars"},
                {text:"haskell",value:"haskell"},
                {text:"haxe",value:"haxe"},
                {text:"http",value:"http"},
                {text:"icon",value:"icon"},
                {text:"inform7",value:"inform7"},
                {text:"ini",value:"ini"},
                {text:"j",value:"j"},
                {text:"jade",value:"jade"},
                {text:"java",value:"java"},
                {text:"JSON",value:"json"},
                {text:"jsonp",value:"jsonp"},
                {text:"julia",value:"julia"},
                {text:"keyman",value:"keyman"},
                {text:"kotlin",value:"kotlin"},
                {text:"latex",value:"latex"},
                {text:"less",value:"less"},
                {text:"lolcode",value:"lolcode"},
                {text:"lua",value:"lua"},
                {text:"makefile",value:"makefile"},
                {text:"markdown",value:"markdown"},
                {text:"matlab",value:"matlab"},
                {text:"mel",value:"mel"},
                {text:"mizar",value:"mizar"},
                {text:"monkey",value:"monkey"},
                {text:"nasm",value:"nasm"},
                {text:"nginx",value:"nginx"},
                {text:"nim",value:"nim"},
                {text:"nix",value:"nix"},
                {text:"nsis",value:"nsis"},
                {text:"objectivec",value:"objectivec"},
                {text:"ocaml",value:"ocaml"},
                {text:"oz",value:"oz"},
                {text:"parigp",value:"parigp"},
                {text:"parser",value:"parser"},
                {text:"pascal",value:"pascal"},
                {text:"perl",value:"perl"},
                {text:"PHP",value:"php"},
                {text:"processing",value:"processing"},
                {text:"prolog",value:"prolog"},
                {text:"protobuf",value:"protobuf"},
                {text:"puppet",value:"puppet"},
                {text:"pure",value:"pure"},
                {text:"python",value:"python"},
                {text:"q",value:"q"},
                {text:"qore",value:"qore"},
                {text:"r",value:"r"},
                {text:"jsx",value:"jsx"},
                {text:"rest",value:"rest"},
                {text:"rip",value:"rip"},
                {text:"roboconf",value:"roboconf"},
                {text:"crystal",value:"crystal"},
                {text:"rust",value:"rust"},
                {text:"sas",value:"sas"},
                {text:"sass",value:"sass"},
                {text:"scss",value:"scss"},
                {text:"scala",value:"scala"},
                {text:"scheme",value:"scheme"},
                {text:"smalltalk",value:"smalltalk"},
                {text:"smarty",value:"smarty"},
                {text:"SQL",value:"sql"},
                {text:"stylus",value:"stylus"},
                {text:"swift",value:"swift"},
                {text:"tcl",value:"tcl"},
                {text:"textile",value:"textile"},
                {text:"twig",value:"twig"},
                {text:"TypeScript",value:"typescript"},
                {text:"verilog",value:"verilog"},
                {text:"vhdl",value:"vhdl"},
                {text:"wiki",value:"wiki"},
                {text:"YAML",value:"yaml"}
            ],
            style_formats: [
                {title: 'Headers', items: [
                        {title: 'Header 1', format: 'h1'},
                        {title: 'Header 2', format: 'h2'},
                        {title: 'Header 3', format: 'h3'},
                        {title: 'Header 4', format: 'h4'},
                        {title: 'Header 5', format: 'h5'},
                        {title: 'Header 6', format: 'h6'}
                    ]},
                {title: 'Inline', items: [
                        {title: 'Bold', icon: 'bold', format: 'bold'},
                        {title: 'Italic', icon: 'italic', format: 'italic'},
                        {title: 'Underline', icon: 'underline', format: 'underline'},
                        {title: 'Strikethrough', icon: 'strikethrough', format: 'strikethrough'},
                        {title: 'Superscript', icon: 'superscript', format: 'superscript'},
                        {title: 'Subscript', icon: 'subscript', format: 'subscript'},
                        {title: 'Code', icon: 'code', format: 'code'}
                    ]},
                {title: 'Blocks', items: [
                        {title: 'Paragraph', format: 'p'},
                        {title: 'Blockquote', format: 'blockquote'},
                        {title: 'Div', format: 'div'},
                        {title: 'Pre', format: 'pre'}
                    ]},
                {title: 'Alignment', items: [
                        {title: 'Left', icon: 'alignleft', format: 'alignleft'},
                        {title: 'Center', icon: 'aligncenter', format: 'aligncenter'},
                        {title: 'Right', icon: 'alignright', format: 'alignright'},
                        {title: 'Justify', icon: 'alignjustify', format: 'alignjustify'}
                    ]}
            ],
            height : 300,
            min_height: 300,
            max_height: 1000,
            promotion: false
        }
    }

    connect () {
        let config = Object.assign({ target: this.fieldTarget }, this.defaults)
        tinymce.init(config)
        console.log(this.fieldTarget.id)
    }

    disconnect () {
        if (!this.preview) tinymce.get(this.fieldTarget.id).remove();
    }

    get preview () {
        return (
            document.documentElement.hasAttribute('data-turbolinks-preview') ||
            document.documentElement.hasAttribute('data-turbo-preview')
        )
    }
}