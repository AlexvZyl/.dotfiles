/**
 * Prefs Library
 *
 * @author     Javad Rahmatzadeh <j.rahmatzadeh@gmail.com>
 * @copyright  2020-2022
 * @license    GPL-3.0-only
 */

/**
 * prefs widget for showing prefs window
 */
var Prefs = class
{
    /**
     * class constructor
     *
     * @param {Object} dependencies
     *   'Builder' instance of Gtk::Builder
     *   'Settings' instance of Gio::Settings
     *   'GObjectBindingFlags' instance of GObject::BindingFlags
     *   'Gtk' reference to Gtk
     *   'Gdk' reference to Gdk
     *   'Gio' reference to Gio
     *   'GLib' reference to GLib
     * @param {PrefsKeys.PrefsKeys} prefsKeys instance of PrefsKeys
     * @param {number} shellVersion float in major.minor format
     */
    constructor(dependencies, prefsKeys, shellVersion)
    {
        this._settings = dependencies['Settings'] || null;
        this._builder = dependencies['Builder'] || null;
        this._gobjectBindingFlags = dependencies['GObjectBindingFlags'] || null;
        this._gtk = dependencies['Gtk'] || null;
        this._gdk = dependencies['Gdk'] || null;
        this._gio = dependencies['Gio'] || null;
        this._glib = dependencies['GLib'] || null;

        this._prefsKeys = prefsKeys;
        this._shellVersion = shellVersion;
        this._gtkVersion = (this._gtk) ? this._gtk.get_major_version() : 3;
        
        /**
         * whether it is called for adwaita window 
         *
         * @member {boolean}
         */
        this._isAdw = false;

        /**
         * holds Gtk.DropDown items that are
         * created inside this._convertComboBoxTextToDropDown()
         * object key is widget id
         *
         * @member {Object}
         */
        this._dropdowns = {};

        /**
         * initial window size
         *
         * @member {number}
         */
        this._windowWidth = 600;
        this._windowHeight = 750;

        /**
         * initial window size for adw
         *
         * @member {number}
         */
         this._windowWidthAdw = 600;
         this._windowHeightAdw = 650;

        /**
         * holds all profile names
         *
         * @member {string}
         */
        this._profiles = [
            'default',
            'minimal',
            'superminimal',
        ];

        /**
         * holds all required urls
         *
         * @member {Object}
         */
        this._url = {
            bug_report: 'https://gitlab.gnome.org/jrahmatzadeh/just-perfection/-/issues',
            patreon: 'https://www.patreon.com/justperfection',
        };
    }

    /**
     * fill prefs window
     *
     * @param {string} UIFolderPath folder path to ui folder
     * @param {string} binFolderPath bin folder path
     * @param {string} gettextDomain gettext domain
     *
     * @returns {void}
     */
     fillPrefsWindow(window, UIFolderPath, binFolderPath, gettextDomain)
     {
        this._isAdw = true;
        
         // changing the order here can change the elements order in ui 
         let uiFilenames = [
             'profile',
             'visibility',
             'icons',
             'behavior',
             'customize',
         ];
 
         this._builder.set_translation_domain(gettextDomain);
         for (let uiFilename of uiFilenames) {
             this._builder.add_from_file(`${UIFolderPath}/adw/${uiFilename}.ui`);
         }

         for (let uiFilename of uiFilenames) {
             let page = this._builder.get_object(uiFilename);
             window.add(page);
         }
 
         this._setValues();
         this._guessProfile();
         this._onlyShowSupportedRows();
         this._registerAllSignals(window);

         this._setWindowSize(window);

         window.search_enabled = true;
     }

    /**
     * get prefs widget
     *
     * @param {string} UIFolderPath folder path to ui folder
     * @param {string} binFolderPath bin folder path
     * @param {string} gettextDomain gettext domain
     *
     * @returns {Object}
     */
    getPrefsWidget(UIFolderPath, binFolderPath, gettextDomain)
    {
        this._isAdw = false;

        // changing the order here can change the elements order in ui 
        let uiFilenames = [
            'main',
            'no-results-found',
            'profile',
            'override',
            'visibility',
            'icons',
            'behavior',
            'customize',
        ];

        // profile is not supported on GNOME Shell 3.x
        if (this._shellVersion < 40) {
            uiFilenames.splice(uiFilenames.indexOf('profile'), 1);
        }

        this._builder.set_translation_domain(gettextDomain);
        for (let uiFilename of uiFilenames) {
            this._builder.add_from_file(`${UIFolderPath}/${uiFilename}.ui`);
        }

        let obj = this._builder.get_object('main_prefs');
        let prefsBox = this._builder.get_object('main_prefs_in_box');

        for (let uiFilename of uiFilenames) {
            if (uiFilename === 'main') {
                continue;
            }
            let elementId = uiFilename.replace(/-/g, '_');
            let elm = this._builder.get_object(elementId);
            if (this._gtkVersion === 3) {
                prefsBox.add(elm);
            } else {
                prefsBox.append(elm);
            }
        }

        this._convertComboBoxTextToDropDown();
        this._fixIconObjects();
        this._setValues();
        this._guessProfile();

        this._onlyShowSupportedRows();

        obj.connect('realize', () => {

            let window = (this._gtkVersion === 3) ? obj.get_toplevel() : obj.get_root();

            this._setWindowSize(window);

            // csd
            let headerBar = this._builder.get_object('header_bar');
            let csdMenu = this._builder.get_object('csd_menu');
            window.set_titlebar(headerBar);
            if (this._gtkVersion === 3) {
                headerBar.set_title('Just Perfection');
                headerBar.set_show_close_button(true);
            }
            headerBar.pack_end(csdMenu);

            this._registerAllSignals(window);
        });

        return obj;
    }

    /**
     * set window size
     *
     * @param {Gtk.Window|Adw.PreferencesWindow} window prefs window
     *
     * @returns {void}
     */
    _setWindowSize(window)
    {
        let [pmWidth, pmHeight, pmScale] = this._getPrimaryMonitorInfo();
        let sizeTolerance = 50;
        let width = (this._isAdw) ? this._windowWidthAdw : this._windowWidth;
        let height = (this._isAdw) ? this._windowHeightAdw : this._windowHeight;

        if (
            (pmWidth/pmScale) - sizeTolerance >= width &&
            (pmHeight/pmScale) - sizeTolerance >= height
        ) {
            if (!this._isAdw) {
                window.default_width = width;
            }
            window.set_default_size(width, height);
            if (this._gtkVersion === 3) {
                window.resize(width, height);
            }
        }
    }

    /**
     * get primary monitor info
     *
     * @returns {Array} [width, height, scale]
     */
    _getPrimaryMonitorInfo()
    {
        let display = this._gdk.Display.get_default();

        let pm
        = (this._gtkVersion === 3)
        ? display.get_monitor(0)
        : display.get_monitors().get_item(0);

        if (!pm) {
            return [700, 500, 1];
        }

        let geo = pm.get_geometry();
        let scale = pm.get_scale_factor();

        return [geo.width, geo.height, scale];
    }

    /**
     * fix images that holding icons for GTK4
     *
     * @returns {void}
     */
    _fixIconObjects()
    {
        if (this._gtkVersion === 3 || this._isAdw) {
            return;
        }

        let icons = [
            'menu_icon',
            'search_icon',
        ];

        icons.forEach(id => {
            let elm = this._builder.get_object(id);
            let parent = elm.get_parent();
            let iconName = elm.get_icon_name();
            let iconSize = elm.get_icon_size();

            parent.icon_name = iconName;
            parent.icon_size = iconSize;
        });
    }

    /**
     * convert all comboboxes to drop down and hold them inside this._dropdowns
     *
     * @returns {void}
     */
    _convertComboBoxTextToDropDown()
    {
        if (this._gtkVersion === 3 || this._isAdw) {
            return;
        }

        for (let [, key] of Object.entries(this._prefsKeys.keys)) {
            if (key.widgetType === 'GtkComboBoxText') {
                let widget = this._builder.get_object(key.widgetId);
                let parent = widget.get_parent();

                let items = [];
                widget.set_active(0);
                let selectedIndex = 0;
                while (widget.get_active_text() !== null) {
                    items.push(widget.get_active_text());
                    selectedIndex++;
                    widget.set_active(selectedIndex);
                }

                let dropdown = this._gtk.DropDown.new_from_strings(items);

                this._prefsKeys.deleteKey(key.id);

                let newKey = this._prefsKeys.setKey(
                    key.category,
                    key.name,
                    'GtkDropDown',
                    key.supported,
                    key.profiles,
                    key.maps
                );

                this._dropdowns[newKey.widgetId] = dropdown;

                dropdown.set_valign(this._gtk.Align.CENTER);

                widget.hide();
                parent.append(dropdown);
            }
        }
    }

    /**
     * register all signals
     *
     * @param {Gtk.Window} window prefs dialog
     *
     * @returns {void}
     */
    _registerAllSignals(window)
    {
        this._registerKeySignals();
        this._registerSearchSignals(window);
        this._registerFileChooserSignals(window);
        this._registerProfileSignals();
        this._registerActionSignals(window);
    }

    /**
     * register signals of all prefs keys
     *
     * @returns {void}
     */
     _registerKeySignals()
     {
         // all available keys
         for (let [, key] of Object.entries(this._prefsKeys.keys)) {
 
             switch (key.widgetType) {
 
                 case 'GtkSwitch':
                     this._builder.get_object(key.widgetId).connect('state-set', (w) => {
                         this._settings.set_boolean(key.name, w.get_active());
                         this._guessProfile();
                     });
                     break;
 
                 case 'GtkComboBoxText':
                     this._builder.get_object(key.widgetId).connect('changed', (w) => {
                         let index = w.get_active();
                         let value = (index in key.maps) ? key.maps[index] : index; 
                         this._settings.set_int(key.name, value);
                         this._guessProfile();
                     });
                     break;
 
                 case 'GtkDropDown':
                     this._dropdowns[key.widgetId].connect('notify::selected-item', (w) => {
                         let index = w.get_selected();
                         let value = (index in key.maps) ? key.maps[index] : index; 
                         this._settings.set_int(key.name, value);
                         this._guessProfile();
                     });
                     break;
 
                 case 'AdwActionRow':
                     this._builder.get_object(key.widgetId).connect('notify::selected-item', (w) => {
                         let index = w.get_selected();
                         let value = (index in key.maps) ? key.maps[index] : index; 
                         this._settings.set_int(key.name, value);
                         this._guessProfile();
                     });
                     break;
 
                 case 'GtkEntry':
                     this._builder.get_object(key.widgetId).connect('changed', (w) => {
                         this._settings.set_string(key.name, w.text);
                         this._guessProfile();
                     });
                     break;
             }
         }
    }

    /**
     * register search signals
     *
     * @param {Gtk.Window} window prefs dialog
     *
     * @returns {void}
     */
    _registerSearchSignals(window)
    {
        if (this._isAdw) {
            return;
        }
    
        let searchEntry = this._builder.get_object('search_entry');
        searchEntry.connect('changed', (w) => {
            this._search(w.get_text());
        });

        let searchBar = this._builder.get_object('searchbar');
        if (this._gtkVersion === 3) {
            window.connect('key-press-event', (w, e) => {
                return searchBar.handle_event(e);
            });
        } else {
            searchBar.set_key_capture_widget(window);
        }

        let searchBtn = this._builder.get_object('search_togglebutton');
        searchBtn.bind_property('active', searchBar, 'search-mode-enabled',
            this._gobjectBindingFlags.BIDIRECTIONAL);

        searchBar.connect_entry(searchEntry);
    }

    /**
     * register file chooser signals
     *
     * @param {Gtk.Window} window prefs dialog
     *
     * @returns {void}
     */
     _registerFileChooserSignals(window)
     {
         let fileChooser = this._builder.get_object('file_chooser');
         let activitiesButtonIconPath = {
             button: this._builder.get_object('activities_button_icon_path_button'),
             entry: this._builder.get_object('activities_button_icon_path_entry'),
             empty: this._builder.get_object('activities_button_icon_path_empty_button'),
         };
 
         activitiesButtonIconPath['entry'].connect('changed', (w) => {
             this._setFileChooserValue('activities_button_icon_path', w.text, true);
         });
 
         activitiesButtonIconPath['empty'].connect('clicked', () => {
             this._setFileChooserValue('activities_button_icon_path', '');
         });
 
         activitiesButtonIconPath['button'].connect('clicked', (w) => {
             this.currentFileChooserEntry = activitiesButtonIconPath['entry'];
 
             let uri = activitiesButtonIconPath['entry'].text;
             let file = this._gio.File.new_for_uri(uri);
             let fileExists = file.query_exists(null);
             if (fileExists) {
                 let fileParent = file.get_parent();
                 fileChooser.set_current_folder(
                     (this._gtkVersion === 3) ? fileParent.get_path() : fileParent
                 );
             }
 
             fileChooser.set_transient_for(window);
             fileChooser.show();
         });
 
         fileChooser.connect('response', (w, response) => {
             if (response !== this._gtk.ResponseType.ACCEPT) {
                 return;
             }
             let fileURI = w.get_file().get_uri();
             this.currentFileChooserEntry.text = fileURI;
         });
    }

    /**
     * register profile signals
     *
     * @returns {void}
     */
    _registerProfileSignals()
    {
        for (let profile of this._profiles) {
            let profileElm = this._builder.get_object(`profile_${profile}`);
            if (!profileElm) {
                break;
            }
            profileElm.connect('clicked', (w) => {
                this._setValues(profile);
            });
        }
    }

    /**
     * register action signals
     *
     * @param {Gtk.Window} window prefs dialog
     *
     * @returns {void}
     */
     _registerActionSignals(window)
     {
        if (this._isAdw) {
            return
        }

        let actionGroup = new this._gio.SimpleActionGroup();

        let action1 = new this._gio.SimpleAction({name: 'show-bug-report'});
        action1.connect('activate', () => {
            this._openURI(window, this._url.bug_report);
        });
        actionGroup.add_action(action1);

        let action2 = new this._gio.SimpleAction({name: 'show-patreon'});
        action2.connect('activate', () => {
            this._openURI(window, this._url.patreon);
        });
        actionGroup.add_action(action2);

        window.insert_action_group('prefs', actionGroup);
     }

    /**
     * open uri
     *
     * @param {string} uri uri to open
     * @param {Gtk.Window} window prefs dialog
     *
     * @returns {void}
     */
    _openURI(window, uri)
    {
        if (this._gtkVersion === 3) {
            this._gtk.show_uri_on_window(window, uri, this._gdk.CURRENT_TIME);
            return;
        }

        this._gtk.show_uri(window, uri, this._gdk.CURRENT_TIME);
    }

    /**
     * can check all current values and guess the profile based on the values
     *
     * @returns {void}
     */
    _guessProfile()
    {
        let totalCount = 0;
        let matchCount = {};

        for (let profile of this._profiles) {
            matchCount[profile] = 0;
        }

        for (let [, key] of Object.entries(this._prefsKeys.keys)) {
        
            if (!key.supported) {
                continue;
            }

            let value;

            switch (key.widgetType) {
                case 'GtkSwitch':
                case 'GtkComboBoxText':
                    value = this._builder.get_object(key.widgetId).get_active();
                    break;
                case 'AdwActionRow':
                    value = this._builder.get_object(key.widgetId).get_selected();
                    break;
                case 'GtkDropDown':
                    value = this._dropdowns[key.widgetId].get_selected();
                    break;
                case 'GtkEntry':
                    value = this._builder.get_object(key.widgetId).text;
                    break;
                default:
                    value = '';
                    continue;
            }
            
            for (let profile of this._profiles) {
                if (key.profiles[profile] === value) {
                    matchCount[profile]++;
                }
            }

            totalCount++;
        }

        let currentProfile = 'custom';
        for (let profile of this._profiles) {
            if (matchCount[profile] === totalCount) {
                currentProfile = profile;
                break;
            }
        }
        
        let profileElm = this._builder.get_object(`profile_${currentProfile}`);
        if (profileElm) {
            profileElm.set_active(true);
        }
    }

    /**
     * set file chooser button value
     *
     * @param {string} id element starter id
     * @param {string} uri file address
     * @param {bool} entrySetBefore whether file chooser entry value has been set before
     *
     * @returns {void}
     */
    _setFileChooserValue(id, uri, entrySetBefore = false)
    {
        let preview = this._builder.get_object(`${id}_preview`);
        let emptyButton = this._builder.get_object(`${id}_empty_button`);
        let entry = this._builder.get_object(`${id}_entry`);

        if (!entry) {
            return;
        }

        let file = this._gio.File.new_for_uri(uri);
        let fileExists = file.query_exists(null);
        let uriPrepared = (fileExists) ? uri : '';

        let visible = uriPrepared !== '';

        if (!entrySetBefore) {
            entry.text = uriPrepared;
        }
        emptyButton.visible = visible;

        preview.clear();

        if (fileExists) {
            let gicon = this._gio.icon_new_for_string(file.get_path());
            if (this._gtkVersion === 3) {
                preview.set_from_gicon(gicon, 1);
            } else {
                preview.set_from_gicon(gicon);
            }
        } else {
            preview.icon_name = 'document-open-symbolic';
        }
    }

    /**
     * set values for all elements
     *
     * @param {string} profile profile name or null for get it from gsettings
     *
     * @returns {void}
     */
    _setValues(profile)
    {
        for (let [, key] of Object.entries(this._prefsKeys.keys)) {

            let elm
            = (key.widgetType === 'GtkDropDown')
            ? this._dropdowns[key.widgetId]
            : this._builder.get_object(key.widgetId);

            switch (key.widgetType) {

                case 'GtkSwitch':
                    let value
                    = (profile)
                    ? key.profiles[profile]
                    : this._settings.get_boolean(key.name);

                    elm.set_active(value);
                    break;

                case 'GtkComboBoxText':
                case 'GtkDropDown':
                case 'AdwActionRow':
                    let index
                    = (profile)
                    ? key.profiles[profile]
                    : this._settings.get_int(key.name);

                    for (let k in key.maps) {
                        if (key.maps[k] === index) {
                            index = k;
                            break;
                        }
                    }
                    if (key.widgetType === 'GtkDropDown' || key.widgetType === 'AdwActionRow') {
                        elm.set_selected(index);
                    } else {
                        elm.set_active(index);
                    }
                    break;

                case 'GtkEntry':
                    let text
                    = (profile)
                    ? key.profiles[profile]
                    : this._settings.get_string(key.name);

                    elm.text = text;
                    this._setFileChooserValue(key.id, elm.text);
                    break;
            }
        }
    }

    /**
     * apply all supported keys to the elements
     *
     * @returns {void}
     */
     _onlyShowSupportedRows()
     {
         if (!this._isAdw) {
            this._search('');
            return;
         }

         for (let [, key] of Object.entries(this._prefsKeys.keys)) {
            let row = this._builder.get_object(`${key.id}_row`);
            let visible = key.supported;
            row.visible = visible;
        }
     }

    /**
     * search the query
     *
     * @param {string} q query
     *
     * @returns {void}
     */
    _search(q)
    {
        let categories = {};
        let noResultsFoundVisibility = true;

        let profile = this._builder.get_object('profile');
        if (profile) {
            profile.visible = (q === '') ? true : false;
        }

        for (let [, key] of Object.entries(this._prefsKeys.keys)) {

            if (categories[key.category] === undefined) {
                categories[key.category] = 0;
            }

            let text = this._builder.get_object(`${key.id}_txt`).get_text();
            let row = this._builder.get_object(`${key.id}_row`);

            let visible = key.supported && text.toLowerCase().includes(q);

            row.visible = visible;

            if (visible) {
                categories[key.category]++;
                noResultsFoundVisibility = false;
            }
        }

        // hide the category when nothing is visible in it
        for (var category in categories) {
            let titleElm = this._builder.get_object(`${category}_title`);
            let frameElm = this._builder.get_object(`${category}_frame`);
            let visible = categories[category] > 0;

            titleElm.visible = visible;
            frameElm.visible = visible;
        }

        let notFound = this._builder.get_object('no_results_found');
        notFound.visible = noResultsFoundVisibility;
    }
};

