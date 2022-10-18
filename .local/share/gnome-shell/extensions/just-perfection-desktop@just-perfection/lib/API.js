/**
 * API Library
 *
 * @author     Javad Rahmatzadeh <j.rahmatzadeh@gmail.com>
 * @copyright  2020-2022
 * @license    GPL-3.0-only
 */

const XY_POSITION = {
    TOP_START: 0,
    TOP_CENTER: 1,
    TOP_END: 2,
    BOTTOM_START: 3,
    BOTTOM_CENTER: 4,
    BOTTOM_END: 5,
    CENTER_START: 6,
    CENTER_CENTER: 7,
    CENTER_END: 8,
};

const PANEL_POSITION = {
    TOP: 0,
    BOTTOM: 1,
};

const PANEL_BOX_POSITION = {
    CENTER: 0,
    RIGHT: 1,
    LEFT: 2,
};

const PANEL_HIDE_MODE = {
    ALL: 0,
    DESKTOP: 1,
};

const SHELL_STATUS = {
    NONE: 0,
    OVERVIEW: 1,
};

const ICON_TYPE = {
    NAME: 0,
    URI: 1,
};

const DASH_ICON_SIZES = [16, 22, 24, 32, 48, 64];

/**
 * API to avoid calling GNOME Shell directly
 * and make all parts compatible with different GNOME Shell versions 
 */
var API = class
{
    /**
     * Class Constructor
     *
     * @param {Object} dependencies
     *   'Main' reference to ui::main
     *   'BackgroundMenu' reference to ui::backgroundMenu
     *   'OverviewControls' reference to ui::overviewControls
     *   'WorkspaceSwitcherPopup' reference to ui::workspaceSwitcherPopup
     *   'InterfaceSettings' reference to Gio::Settings for 'org.gnome.desktop.interface'
     *   'SearchController' reference to ui::searchController
     *   'ViewSelector' reference to ui::viewSelector
     *   'WorkspaceThumbnail' reference to ui::workspaceThumbnail
     *   'WorkspacesView' reference to ui::workspacesView
     *   'Panel' reference to ui::panel
     *   'WindowPreview' reference to ui::windowPreview
     *   'Workspace' reference to ui::workspace
     *   'LookingGlass' reference to ui::lookingGlass
     *   'MessageTray' reference to ui::messageTray
     *   'OSDWindow' reference to ui::osdTray
     *   'WindowMenu' reference to ui::windowMenu
     *   'AltTab' reference to ui::altTab
     *   'St' reference to St
     *   'Gio' reference to Gio
     *   'GLib' reference to GLib
     *   'Clutter' reference to Clutter
     *   'Util' reference to misc::util
     *   'Meta' reference to Meta
     *   'GObject' reference to GObject
     * @param {number} shellVersion float in major.minor format
     */
    constructor(dependencies, shellVersion)
    {
        this._main = dependencies['Main'] || null;
        this._backgroundMenu = dependencies['BackgroundMenu'] || null;
        this._overviewControls = dependencies['OverviewControls'] || null;
        this._workspaceSwitcherPopup = dependencies['WorkspaceSwitcherPopup'] || null;
        this._interfaceSettings = dependencies['InterfaceSettings'] || null;
        this._searchController = dependencies['SearchController'] || null;
        this._viewSelector = dependencies['ViewSelector'] || null;
        this._workspaceThumbnail = dependencies['WorkspaceThumbnail'] || null;
        this._workspacesView = dependencies['WorkspacesView'] || null;
        this._panel = dependencies['Panel'] || null;
        this._windowPreview = dependencies['WindowPreview'] || null;
        this._workspace = dependencies['Workspace'] || null;
        this._lookingGlass = dependencies['LookingGlass'] || null;
        this._messageTray = dependencies['MessageTray'] || null;
        this._osdWindow = dependencies['OSDWindow'] || null;
        this._windowMenu = dependencies['WindowMenu'] || null;
        this._altTab = dependencies['AltTab'] || null;
        this._st = dependencies['St'] || null;
        this._gio = dependencies['Gio'] || null;
        this._glib = dependencies['GLib'] || null;
        this._clutter = dependencies['Clutter'] || null;
        this._util = dependencies['Util'] || null;
        this._meta = dependencies['Meta'] || null;
        this._gobject = dependencies['GObject'] || null;

        this._shellVersion = shellVersion;
        this._originals = {};
        this._timeoutIds = {};

        /**
         * whether search entry is visible
         *
         * @member {boolean}
         */
        this._searchEntryVisibility = true;

        /**
         * last workspace switcher size in float
         *
         * @member {number}
         */
        this._workspaceSwitcherLastSize
        = (this._workspaceThumbnail && this._shellVersion >= 40)
        ? this._workspaceThumbnail.MAX_THUMBNAIL_SCALE
        : 0.0;
    }

    /**
     * prepare everything needed for API
     *
     * @returns {void}
     */
    open()
    {
        this.UIStyleClassAdd(this._getAPIClassname('shell-version'));
    }

    /**
     * remove everything from GNOME Shell been added by this class 
     *
     * @returns {void}
     */
    close()
    {
        this.UIStyleClassRemove(this._getAPIClassname('shell-version'));
        this._startSearchSignal(false);
        
        for (let [name, id] of Object.entries(this._timeoutIds)) {
            this._glib.source_remove(id);
            delete(this._timeoutIds[name]);
        }
    }

    /**
     * get x and y align for position
     *
     * @param int pos position
     *   see XY_POSITION
     *
     * @returns {array}
     *  - 0 Clutter.ActorAlign
     *  - 1 Clutter.ActorAlign
     */
    _xyAlignGet(pos)
    {
        if (XY_POSITION.TOP_START === pos) {
            return [this._clutter.ActorAlign.START, this._clutter.ActorAlign.START];
        }

        if (XY_POSITION.TOP_CENTER === pos) {
            return [this._clutter.ActorAlign.CENTER, this._clutter.ActorAlign.START];
        }

        if (XY_POSITION.TOP_END === pos) {
            return [this._clutter.ActorAlign.END, this._clutter.ActorAlign.START];
        }

        if (XY_POSITION.CENTER_START === pos) {
            return [this._clutter.ActorAlign.START, this._clutter.ActorAlign.CENTER];
        }

        if (XY_POSITION.CENTER_CENTER === pos) {
            return [this._clutter.ActorAlign.CENTER, this._clutter.ActorAlign.CENTER];
        }

        if (XY_POSITION.CENTER_END === pos) {
            return [this._clutter.ActorAlign.END, this._clutter.ActorAlign.CENTER];
        }

        if (XY_POSITION.BOTTOM_START === pos) {
            return [this._clutter.ActorAlign.START, this._clutter.ActorAlign.END];
        }

        if (XY_POSITION.BOTTOM_CENTER === pos) {
            return [this._clutter.ActorAlign.CENTER, this._clutter.ActorAlign.END];
        }

        if (XY_POSITION.BOTTOM_END === pos) {
            return [this._clutter.ActorAlign.END, this._clutter.ActorAlign.END];
        }
    }

    /**
     * add to animation duration
     *
     * @param {number} duration in milliseconds
     *
     * @returns {number}
     */
    _addToAnimationDuration(duration)
    {
        let settings = this._st.Settings.get();

        return (settings.enable_animations) ? settings.slow_down_factor * duration : 1;
    }

    /**
     * get signal id of the event
     *
     * @param {Gtk.Widget} widget to find signal in
     * @param {string} signalName signal name
     *
     * @returns {number}
     */
    _getSignalId(widget, signalName)
    {
        return this._gobject.signal_handler_find(widget, { signalId: signalName });
    }

    /**
     * get the css classname for API
     *
     * @param {string} type possible types
     *  shell-version
     *  no-search
     *  no-workspace
     *  no-panel
     *  panel-corner
     *  no-window-picker-icon
     *  type-to-search
     *  no-power-icon
     *  bottom-panel
     *  no-panel-arrow
     *  no-panel-notification-icon
     *  no-app-menu-icon
     *  no-app-menu-label
     *  no-show-apps-button
     *  activities-button-icon
     *  activities-button-icon-monochrome
     *  activities-button-no-label
     *  dash-icon-size
     *  panel-button-padding-size
     *  panel-indicator-padding-size
     *  no-window-caption
     *  workspace-background-radius-size
     *  no-window-close
     *  refresh-styles
     *  no-ripple-box
     *  no-weather
     *  no-world-clocks
     *  panel-icon-size
     *  no-events-button
     *  osd-position-top
     *  osd-position-bottom
     *  osd-position-center
     *  no-dash-separator
     *
     * @returns {string}
     */
    _getAPIClassname(type)
    {
        let starter = 'just-perfection-api-';

        let possibleTypes = [
            'shell-version',
            'no-search',
            'no-workspace',
            'no-panel',
            'panel-corner',
            'no-window-picker-icon',
            'type-to-search',
            'no-power-icon',
            'bottom-panel',
            'no-panel-arrow',
            'no-panel-notification-icon',
            'no-app-menu-icon',
            'no-app-menu-label',
            'no-show-apps-button',
            'activities-button-icon',
            'activities-button-icon-monochrome',
            'activities-button-no-label',
            'dash-icon-size',
            'panel-button-padding-size',
            'panel-indicator-padding-size',
            'no-window-caption',
            'workspace-background-radius-size',
            'no-window-close',
            'refresh-styles',
            'no-ripple-box',
            'no-weather',
            'no-world-clocks',
            'panel-icon-size',
            'no-events-button',
            'osd-position-top',
            'osd-position-bottom',
            'osd-position-center',
            'no-dash-separator',
        ];

        if (!possibleTypes.includes(type)) {
            return '';
        }

        if (type === 'shell-version') {
            let shellVerMajor = Math.trunc(this._shellVersion);
            return `${starter}gnome${shellVerMajor}`;
        }

        return starter + type;
    }

    /**
     * allow shell theme use its own panel corner
     *
     * @returns {void}
     */
    panelCornerSetDefault()
    {
        if (this._shellVersion >= 42) {
            return;
        }

        let classnameStarter = this._getAPIClassname('panel-corner');

        for (let size = 0; size <= 60; size++) {
            this.UIStyleClassRemove(classnameStarter + size);
        }
    }

    /**
     * change panel corner size
     *
     * @param {number} size 0 to 60
     *
     * @returns {void}
     */
    panelCornerSetSize(size)
    {
        if (this._shellVersion >= 42) {
            return;
        }

        this.panelCornerSetDefault();

        if (size > 60 || size < 0) {
            return;
        }

        let classnameStarter = this._getAPIClassname('panel-corner');

        this.UIStyleClassAdd(classnameStarter + size);
    }

    /**
     * set panel size to default
     *
     * @returns {void}
     */
    panelSetDefaultSize()
    {
        if (!this._originals['panelHeight']) {
            return;
        }

        this.panelSetSize(this._originals['panelHeight'], false);
    }

    /**
     * change panel size
     *
     * @param {number} size 0 to 100
     * @param {boolean} fake true means it shouldn't change the last size,
     *   false otherwise
     *
     * @returns {void}
     */
    panelSetSize(size, fake)
    {
        if (!this._originals['panelHeight']) {
            this._originals['panelHeight'] = this._main.panel.height;
        }

        if (size > 100 || size < 0) {
            return;
        }

        this._main.panel.height = size;

        if (!fake) {
            this._panelSize = size;
        }

        // to fix panel not getting out of place
        this._emitPanelPositionChanged();
    }

    /**
     * get the last size of the panel
     *
     * @returns {number}
     */
    panelGetSize()
    {
        if (this._panelSize !== undefined) {
            return this._panelSize;
        }

        if (this._originals['panelHeight']) {
            return this._originals['panelHeight'];
        }

        return this._main.panel.height;
    }

    /**
     * emit refresh styles
     * this is useful when changed style doesn't emit change because doesn't have
     * standard styles. for example, style with only `-natural-hpadding`
     * won't notify any change. so you need to call this function
     * to refresh that
     *
     * @returns {void}
     */
    _emitRefreshStyles()
    {
        let classname = this._getAPIClassname('refresh-styles');

        this.UIStyleClassAdd(classname);
        this.UIStyleClassRemove(classname);
    }

    /**
     * emit changed signal for panel position
     *
     * @param {boolean} calledFromChanger whether it is called from 
     *   position changer. you should never call it with false from
     *   this.panelSetPosition() since it can cause recursion.
     *
     * @returns {void}
     */
    _emitPanelPositionChanged(calledFromChanger = false)
    {
        if (this._timeoutIds['emitPanelPositionChanged']) {
            this._glib.source_remove(this._timeoutIds['emitPanelPositionChanged']);
            delete(this._timeoutIds['emitPanelPositionChanged']);
        }

        if (this._timeoutIds['emitPanelPositionChanged2']) {
            this._glib.source_remove(this._timeoutIds['emitPanelPositionChanged2']);
            delete(this._timeoutIds['emitPanelPositionChanged2']);
        }

        if (!calledFromChanger) {
            this.panelSetPosition(this.panelGetPosition(), true);
        }

        if (!this.isPanelVisible()) {
            let mode = this._panelHideMode ? this._panelHideMode : 0;
            this.panelHide(mode, 0);
        } else {
            // resize panel can fix windows going under panel
            // we may not need it on X11, but it is needed on Wayland
            // we also need delay after animation
            // because without delay it many not fix the issue
            let panelBox = this._main.layoutManager.panelBox;
            let duration = this._addToAnimationDuration(180);
            this._timeoutIds['emitPanelPositionChanged']
            = this._glib.timeout_add(this._glib.PRIORITY_IDLE, duration, () => {
                delete(this._timeoutIds['emitPanelPositionChanged']);
                this._main.panel.height++;
                this._timeoutIds['emitPanelPositionChangedIn2']
                = this._glib.timeout_add(this._glib.PRIORITY_IDLE, 20, () => {
                    this._main.panel.height--;
                    delete(this._timeoutIds['emitPanelPositionChangedIn2']);
                    return this._glib.SOURCE_REMOVE;
                });
                return this._glib.SOURCE_REMOVE;
            });
        }

        this._fixLookingGlassPosition();
    }

    /**
     * show panel
     *
     * @param {number} animationDuration in milliseconds. defaults to 150 
     *
     * @returns {void}
     */
    panelShow(animationDuration = 150)
    {
        this._panelVisibility = true;

        let classname = this._getAPIClassname('no-panel');

        if (!this.UIStyleClassContain(classname)) {
            return;
        }

        let overview = this._main.overview;
        let searchEntryParent = overview.searchEntry.get_parent();
        let panelBox = this._main.layoutManager.panelBox;
        
        this._main.layoutManager.removeChrome(panelBox);
        this._main.layoutManager.addChrome(panelBox, {
            affectsStruts: true,
            trackFullscreen: true,
        });

        panelBox.ease({
            translation_y: 0,
            mode: this._clutter.AnimationMode.EASE,
            duration: animationDuration,
            onComplete: () => {
                // hide and show can fix windows going under panel
                panelBox.hide();
                panelBox.show();
                this._fixLookingGlassPosition();
            },
        });

        if (this._overviewShowingSignal) {
            overview.disconnect(this._overviewShowingSignal);
            delete(this._overviewShowingSignal);
        }

        if (this._overviewHidingSignal) {
            overview.disconnect(this._overviewHidingSignal);
            delete(this._overviewHidingSignal);
        }

        if (this._hidePanelWorkareasChangedSignal) {
            global.display.disconnect(this._hidePanelWorkareasChangedSignal);
            delete(this._hidePanelWorkareasChangedSignal);
        }

        searchEntryParent.set_style(`margin-top: 0;`);

        this.UIStyleClassRemove(classname);
    }

    /**
     * hide panel
     *
     * @param {mode} hide mode see PANEL_HIDE_MODE. defaults to hide all
     * @param {boolean} force apply hide even if it is hidden
     * @param {number} animationDuration in milliseconds. defaults to 150
     *
     * @returns {void}
     */
    panelHide(mode, animationDuration = 150)
    {
        this._panelVisibility = false;
        this._panelHideMode = mode;

        let overview = this._main.overview;
        let searchEntryParent = overview.searchEntry.get_parent();
        let panelBox = this._main.layoutManager.panelBox;
        let panelHeight = this._main.panel.height;
        let direction = (this.panelGetPosition() === PANEL_POSITION.BOTTOM) ? 1 : -1;

        this._main.layoutManager.removeChrome(panelBox);
        this._main.layoutManager.addChrome(panelBox, {
            affectsStruts: false,
            trackFullscreen: true,
        });

        panelBox.ease({
            translation_y: panelHeight * direction,
            mode: this._clutter.AnimationMode.EASE,
            duration: animationDuration,
            onComplete: () => {
                // hide and show can fix windows going under panel
                panelBox.hide();
                panelBox.show();
                this._fixLookingGlassPosition();
            },
        });

        searchEntryParent.set_style(`margin-top: 0;`);

        if (this._overviewShowingSignal) {
            overview.disconnect(this._overviewShowingSignal);
            delete(this._overviewShowingSignal);
        }
        if (this._overviewHidingSignal) {
            overview.disconnect(this._overviewHidingSignal);
            delete(this._overviewHidingSignal);
        }

        let appMenuOriginalVisibility;

        if (mode === PANEL_HIDE_MODE.DESKTOP) {
            if (!this._overviewShowingSignal) {
                this._overviewShowingSignal = overview.connect('showing', () => {
                    appMenuOriginalVisibility = this.isAppMenuVisible(); 
                    this.appMenuHide();
                    panelBox.ease({
                        translation_y: 0,
                        mode: this._clutter.AnimationMode.EASE,
                        duration: 250,
                    });
                });
            }
            if (!this._overviewHidingSignal) {
                this._overviewHidingSignal = overview.connect('hiding', () => {
                    panelBox.ease({
                        translation_y: panelHeight * direction,
                        mode: this._clutter.AnimationMode.EASE,
                        duration: 250,
                        onComplete: () => {
                            if (appMenuOriginalVisibility) {
                                this.appMenuShow();
                            } else {
                                this.appMenuHide();
                            }
                        },
                    });
                });
            }
            searchEntryParent.set_style(`margin-top: ${panelHeight}px;`);
        }

        if (this._hidePanelWorkareasChangedSignal) {
            global.display.disconnect(this._hidePanelWorkareasChangedSignal);
            delete(this._hidePanelWorkareasChangedSignal);
        }

        this._hidePanelWorkareasChangedSignal
        = global.display.connect('workareas-changed', () => {
            this.panelHide(this._panelHideMode, 0);
        });

        // when panel is hidden and search entry is visible,
        // the search entry gets too close to the top, so we fix it with margin
        // on GNOME 3 we need to have top and bottom margin for correct proportion
        // but on GNOME 40 we don't need to keep proportion but give it more
        // top margin to keep it less close to top
        let classname = this._getAPIClassname('no-panel');
        this.UIStyleClassAdd(classname);
    }

    /**
     * check whether panel is visible
     *
     * @returns {boolean}
     */
    isPanelVisible()
    {
        if (this._panelVisibility === undefined) {
            return true;
        }

        return this._panelVisibility;
    }

    /**
     * check whether dash is visible
     *
     * @returns {boolean}
     */
    isDashVisible()
    {
        return this._dashVisibility === undefined || this._dashVisibility;
    }

    /**
     * show dash
     *
     * @returns {void}
     */
    dashShow()
    {
        if (!this._main.overview.dash || this.isDashVisible()) {
            return;
        }

        this._dashVisibility = true;

        this._main.overview.dash.show();

        if (this._shellVersion >= 40) {
            this._main.overview.dash.height = -1;
            this._main.overview.dash.setMaxSize(-1, -1);
        } else {
            this._main.overview.dash.width = -1;
            this._main.overview.dash._maxHeight = -1;
        }

        this._updateWindowPreviewOverlap();
    }

    /**
     * hide dash
     *
     * @returns {void}
     */
    dashHide()
    {
        if (!this._main.overview.dash || !this.isDashVisible()) {
            return;
        }

        this._dashVisibility = false;

        this._main.overview.dash.hide();

        if (this._shellVersion >= 40) {
            this._main.overview.dash.height = 0;
        } else {
            this._main.overview.dash.width = 0;
        }

        this._updateWindowPreviewOverlap();
    }

    /**
     * update window preview overlap
     *
     * @returns {void}
     */
    _updateWindowPreviewOverlap()
    {
        if (this._shellVersion < 40) {
            return;
        }
        
        let wpp = this._windowPreview.WindowPreview.prototype;
        
        if (this.isDashVisible() && wpp.overlapHeightsOld) {
            wpp.overlapHeights = wpp.overlapHeightsOld;
            delete(wpp.overlapHeightsOld);
            return;
        }
        
        if (!this.isDashVisible()) {
            wpp.overlapHeightsOld = wpp.overlapHeights;
            wpp.overlapHeights = function () {
                let [top, bottom] = this.overlapHeightsOld();
                return [top + 24, bottom + 24];
            };
        }
    }

    /**
     * enable gesture
     *
     * @returns {void}
     */
    gestureEnable()
    {
        if (this._shellVersion >= 40) {
            return;
        }

        global.stage.get_actions().forEach(a => {
            a.enabled = true;
        });
    }

    /**
     * disable gesture
     *
     * @returns {void}
     */
    gestureDisable()
    {
        if (this._shellVersion >= 40) {
            return;
        }

        global.stage.get_actions().forEach(a => {
            a.enabled = false;
        });
    }

    /**
     * add class name to the UI group
     *
     * @param {string} classname class name
     *
     * @returns {void}
     */
    UIStyleClassAdd(classname)
    {
        this._main.layoutManager.uiGroup.add_style_class_name(classname);
    }

    /**
     * remove class name from UI group
     *
     * @param {string} classname class name
     *
     * @returns {void}
     */
    UIStyleClassRemove(classname)
    {
        this._main.layoutManager.uiGroup.remove_style_class_name(classname);
    }

    /**
     * check whether UI group has class name
     *
     * @param {string} classname class name
     *
     * @returns {boolean}
     */
    UIStyleClassContain(classname)
    {
        return this._main.layoutManager.uiGroup.has_style_class_name(classname);
    }

    /**
     * enable background menu
     *
     * @returns {void}
     */
    backgroundMenuEnable()
    {
        if (!this._originals['backgroundMenu']) {
            return;
        }

        this._backgroundMenu.BackgroundMenu.prototype.open
        = this._originals['backgroundMenu'];
    }

    /**
     * disable background menu
     *
     * @returns {void}
     */
    backgroundMenuDisable()
    {
        if (!this._originals['backgroundMenu']) {
            this._originals['backgroundMenu']
            = this._backgroundMenu.BackgroundMenu.prototype.open;
        }

        this._backgroundMenu.BackgroundMenu.prototype.open = () => {};
    }

    /**
     * show search
     *
     * @param {boolean} fake true means it just needs to do the job but
     *   don't need to change the search visibility status
     *
     * @returns {void}
     */
    searchEntryShow(fake)
    {
        let classname = this._getAPIClassname('no-search');

        if (!this.UIStyleClassContain(classname)) {
            return;
        }

        this.UIStyleClassRemove(classname);

        let searchEntry = this._main.overview.searchEntry;
        let searchEntryParent = searchEntry.get_parent();

        searchEntryParent.ease({
            height: searchEntry.height,
            opacity: 255,
            mode: this._clutter.AnimationMode.EASE,
            duration: 110,
            onComplete: () => {
                searchEntryParent.height = -1;
                searchEntry.ease({
                    opacity: 255,
                    mode: this._clutter.AnimationMode.EASE,
                    duration: 700,
                });
            },
        });

        if (!fake) {
            this._searchEntryVisibility = true;
        }
    }

    /**
     * hide search
     *
     * @param {boolean} fake true means it just needs to do the job
     *   but don't need to change the search visibility status
     *
     * @returns {void}
     */
    searchEntryHide(fake)
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-search'));

        let searchEntry = this._main.overview.searchEntry;
        let searchEntryParent = searchEntry.get_parent();

        searchEntry.ease({
            opacity: 0,
            mode: this._clutter.AnimationMode.EASE,
            duration: 50,
        });

        searchEntryParent.ease({
            height: 0,
            opacity: 0,
            mode: this._clutter.AnimationMode.EASE,
            duration: 120,
        });

        if (!fake) {
            this._searchEntryVisibility = false;
        }
    }

    /**
     * enable start search
     *
     * @returns {void}
     */
    startSearchEnable()
    {
        this._startSearchSignal(true);

        if (!this._originals['startSearch']) {
            return;
        }

        let viewSelector
        = this._main.overview.viewSelector || this._main.overview._overview.viewSelector;

        if (this._shellVersion >= 40 && this._searchController) {
            this._searchController.SearchController.prototype.startSearch
            = this._originals['startSearch'];
        } else {
            viewSelector.startSearch = this._originals['startSearch'];
        }
    }

    /**
     * disable start search
     *
     * @returns {void}
     */
    startSearchDisable()
    {
        this._startSearchSignal(false);

        let overview = this._main.overview;
        let viewSelector = overview.viewSelector || overview.viewSelector;

        if (!this._originals['startSearch']) {
            this._originals['startSearch']
            = (this._shellVersion >= 40 && this._searchController)
            ? this._searchController.SearchController.prototype.startSearch
            : viewSelector.startSearch;
        }

        if (this._shellVersion >= 40 && this._searchController) {
            this._searchController.SearchController.prototype.startSearch = () => {};
        } else {
            viewSelector.startSearch = () => {};
        }
    }

    /**
     * add search signals that needs to be show search entry when the
     * search entry is hidden
     *
     * @param {boolean} add true means add the signal, false means remove 
     *   the signal
     *
     * @returns {void}
     */
    _startSearchSignal(add)
    {
        let controller
        = this._main.overview.viewSelector ||
          this._main.overview._overview.viewSelector ||
          this._main.overview._overview.controls._searchController;

        // remove
        if (!add) {
            if (this._searchActiveSignal) {
                controller.disconnect(this._searchActiveSignal);
                this._searchActiveSignal = null;
            }
            return;
        }

        // add
        if (this._searchActiveSignal) {
            return;
        }

        let bySearchController = this._shellVersion >= 40;

        let signalName = (bySearchController) ? 'notify::search-active' : 'page-changed';

        this._searchActiveSignal = controller.connect(signalName, () => {
            if (this._searchEntryVisibility) {
                return;
            }

            let inSearch
            = (bySearchController)
            ? controller.searchActive
            : (controller.getActivePage() === this._viewSelector.ViewPage.SEARCH);

            if (inSearch) {
                this.UIStyleClassAdd(this._getAPIClassname('type-to-search'));
                this.searchEntryShow(true);
            } else {
                this.UIStyleClassRemove(this._getAPIClassname('type-to-search'));
                this.searchEntryHide(true);
            }
        });
    }

    /**
     * enable OSD
     *
     * @returns {void}
     */
    OSDEnable()
    {
        if (!this._originals['osdWindowManagerShow']) {
            return;
        }

        this._main.osdWindowManager.show = this._originals['osdWindowManagerShow'];
    }

    /**
     * disable OSD
     *
     * @returns {void}
     */
    OSDDisable()
    {
        if (!this._originals['osdWindowManagerShow']) {
            this._originals['osdWindowManagerShow']
            = this._main.osdWindowManager.show;
        }

        this._main.osdWindowManager.show = () => {};
    }

    /**
     * enable workspace popup
     *
     * @returns {void}
     */
    workspacePopupEnable()
    {
        if (this._shellVersion < 42) {
            if (!this._originals['workspaceSwitcherPopupShow']) {
                return;
            }
            this._workspaceSwitcherPopup.WorkspaceSwitcherPopup.prototype._show
            = this._originals['workspaceSwitcherPopupShow'];

            return;
        }

        if (!this._originals['workspaceSwitcherPopupDisplay']) {
            return;
        }

        this._workspaceSwitcherPopup.WorkspaceSwitcherPopup.prototype.display
        = this._originals['workspaceSwitcherPopupDisplay']
    }

    /**
     * disable workspace popup
     *
     * @returns {void}
     */
    workspacePopupDisable()
    {
        if (this._shellVersion < 42) {
            if (!this._originals['workspaceSwitcherPopupShow']) {
                this._originals['workspaceSwitcherPopupShow']
                = this._workspaceSwitcherPopup.WorkspaceSwitcherPopup.prototype._show;
            }
            this._workspaceSwitcherPopup.WorkspaceSwitcherPopup.prototype._show = () => {
               return false;
            };

            return;
        }

        if (!this._originals['workspaceSwitcherPopupDisplay']) {
            this._originals['workspaceSwitcherPopupDisplay']
            = this._workspaceSwitcherPopup.WorkspaceSwitcherPopup.prototype.display;
        }

        this._workspaceSwitcherPopup.WorkspaceSwitcherPopup.prototype.display = (index) => {
           return false;
        };
    }

    /**
     * show workspace switcher
     *
     * @returns {void}
     */
    workspaceSwitcherShow()
    {
        if (this._shellVersion < 40) {

            if (!this._originals['getAlwaysZoomOut'] ||
                !this._originals['getNonExpandedWidth'])
            {
                return;
            }

            let TSProto = this._overviewControls.ThumbnailsSlider.prototype;

            TSProto._getAlwaysZoomOut = this._originals['getAlwaysZoomOut'];
            TSProto.getNonExpandedWidth = this._originals['getNonExpandedWidth'];
        }

        // it should be before setting the switcher size
        // because the size can be changed by removing the api class
        this.UIStyleClassRemove(this._getAPIClassname('no-workspace'));

        if (this._workspaceSwitcherLastSize) {
            this.workspaceSwitcherSetSize(this._workspaceSwitcherLastSize, false);
        } else {
            this.workspaceSwitcherSetDefaultSize();
        }
    }

    /**
     * hide workspace switcher
     *
     * @returns {void}
     */
    workspaceSwitcherHide()
    {
        if (this._shellVersion < 40) {

            let TSProto = this._overviewControls.ThumbnailsSlider.prototype;

            if (!this._originals['getAlwaysZoomOut']) {
                this._originals['getAlwaysZoomOut'] = TSProto._getAlwaysZoomOut;
            }

            if (!this._originals['getNonExpandedWidth']) {
                this._originals['getNonExpandedWidth'] = TSProto.getNonExpandedWidth;
            }

            TSProto._getAlwaysZoomOut = () => {
                return false;
            };
            TSProto.getNonExpandedWidth = () => {
                return 0;
            };
        }

        this.workspaceSwitcherSetSize(0.0, true);

        // on GNOME 3.38
        //   fix extra space that 3.38 leaves for no workspace with css
        // on GNOME 40
        //   we can hide the workspace only with css by scale=0 and
        //   no padding
        this.UIStyleClassAdd(this._getAPIClassname('no-workspace'));
    }

    /**
     * check whether workspace switcher is visible
     *
     * @returns {boolean}
     */
    isWorkspaceSwitcherVisible()
    {
        return !this.UIStyleClassContain(this._getAPIClassname('no-workspace'));
    }

    /**
     * get Secondary Monitor Display
     *
     * @returns {ui.WorkspacesView.SecondaryMonitorDisplay}
     */
    _getSecondaryMonitorDisplay()
    {
        if (this._shellVersion < 40) {
            return null;
        }

        // for some reason the first time we get the value it returns null in 42
        // but it returns the correct value in second get
        this._workspacesView.SecondaryMonitorDisplay;

        return this._workspacesView.SecondaryMonitorDisplay;
    }

    /**
     * set workspace switcher to its default size
     *
     * @returns {void}
     */
    workspaceSwitcherSetDefaultSize()
    {
        if (this._shellVersion < 40) {
            return;
        }

        if (this._originals['MAX_THUMBNAIL_SCALE'] === undefined) {
            return;
        }

        let size = this._originals['MAX_THUMBNAIL_SCALE'];

        if (this.isWorkspaceSwitcherVisible()) {
            this._workspaceThumbnail.MAX_THUMBNAIL_SCALE = size;
        }

        if (this._originals['smd_getThumbnailsHeight'] !== undefined) {
            let smd = this._getSecondaryMonitorDisplay();
            smd.prototype._getThumbnailsHeight = this._originals['smd_getThumbnailsHeight'];
        }

        this._workspaceSwitcherLastSize = size;
    }

    /**
     * set workspace switcher size
     *
     * @param {number} size in float
     * @param {boolean} fake true means don't change 
     *   this._workspaceSwitcherLastSize, false otherwise
     *
     * @returns {void}
     */
    workspaceSwitcherSetSize(size, fake)
    {
        if (this._shellVersion < 40) {
            return;
        }

        if (this._originals['MAX_THUMBNAIL_SCALE'] === undefined) {
            this._originals['MAX_THUMBNAIL_SCALE']
            = this._workspaceThumbnail.MAX_THUMBNAIL_SCALE;
        }

        if (this.isWorkspaceSwitcherVisible()) {

            this._workspaceThumbnail.MAX_THUMBNAIL_SCALE = size;

            // >>
            // we are overriding the _getThumbnailsHeight() here with the same
            // function as original but we change the MAX_THUMBNAIL_SCALE to our
            // custom size.
            // we do this because MAX_THUMBNAIL_SCALE is const and cannot be changed
            let smd = this._getSecondaryMonitorDisplay();

            if (this._originals['smd_getThumbnailsHeight'] === undefined) {
                this._originals['smd_getThumbnailsHeight'] = smd.prototype._getThumbnailsHeight;
            }

            smd.prototype._getThumbnailsHeight = function(box) {
                if (!this._thumbnails.visible)
                    return 0;

                const [width, height] = box.get_size();
                const {expandFraction} = this._thumbnails;
                const [thumbnailsHeight] = this._thumbnails.get_preferred_height(width);

                return Math.min(
                    thumbnailsHeight * expandFraction,
                    height * size);
            }
            // <<
        }

        if (!fake) {
            this._workspaceSwitcherLastSize = size;
        }
    }

    /**
     * add element to stage
     *
     * @param {St.Widget} element widget 
     *
     * @returns {void}
     */
    chromeAdd(element)
    {
        this._main.layoutManager.addChrome(element, {
            affectsInputRegion : true,
            affectsStruts : false,
            trackFullscreen : true,
        });
    }

    /**
     * remove element from stage
     *
     * @param {St.Widget} element widget 
     *
     * @returns {void}
     */
    chromeRemove(element)
    {
        this._main.layoutManager.removeChrome(element);
    }

    /**
     * show activities button
     *
     * @returns {void}
     */
    activitiesButtonShow()
    {
        if (!this.isLocked()) {
            this._main.panel.statusArea['activities'].container.show();
        }
    }

    /**
     * hide activities button
     *
     * @returns {void}
     */
    activitiesButtonHide()
    {
        this._main.panel.statusArea['activities'].container.hide();
    }

    /**
     * show app menu
     *
     * @returns {void}
     */
    appMenuShow()
    {
        if (!this.isLocked()) {
            this._main.panel.statusArea['appMenu'].container.show();
        }
    }

    /**
     * hide app menu
     *
     * @returns {void}
     */
    appMenuHide()
    {
        this._main.panel.statusArea['appMenu'].container.hide();
    }
    
    /**
     * check whether app menu is visible
     *
     * @returns {boolean}
     */
    isAppMenuVisible()
    {
        return this._main.panel.statusArea['appMenu'].container.visible;
    }

    /**
     * show date menu
     *
     * @returns {void}
     */
    dateMenuShow()
    {
        if (!this.isLocked()) {
            this._main.panel.statusArea['dateMenu'].container.show();
        }
    }

    /**
     * hide date menu
     *
     * @returns {void}
     */
    dateMenuHide()
    {
        this._main.panel.statusArea['dateMenu'].container.hide();
    }

    /**
     * show keyboard layout
     *
     * @returns {void}
     */
    keyboardLayoutShow()
    {
        this._main.panel.statusArea['keyboard'].container.show();
    }

    /**
     * hide keyboard layout
     *
     * @returns {void}
     */
    keyboardLayoutHide()
    {
        this._main.panel.statusArea['keyboard'].container.hide();
    }

    /**
     * show accessibility menu
     *
     * @returns {void}
     */
    accessibilityMenuShow()
    {
        this._main.panel.statusArea['a11y'].container.show();
    }

    /**
     * hide accessibility menu
     *
     * @returns {void}
     */
    accessibilityMenuHide()
    {
        this._main.panel.statusArea['a11y'].container.hide();
    }

    /**
     * show quick settings menu
     *
     * @returns {void}
     */
    quickSettingsMenuShow()
    {
        if (this._shellVersion < 43) {
            return;
        }

        this._main.panel.statusArea['quickSettings'].container.show();
    }

    /**
     * hide quick settings menu
     *
     * @returns {void}
     */
    quickSettingsMenuHide()
    {
        if (this._shellVersion < 43) {
            return;
        }

        this._main.panel.statusArea['quickSettings'].container.hide();
    }

    /**
     * show aggregate menu
     *
     * @returns {void}
     */
    aggregateMenuShow()
    {
        if (this._shellVersion >= 43) {
            return;
        }

        this._main.panel.statusArea['aggregateMenu'].container.show();
    }

    /**
     * hide aggregate menu
     *
     * @returns {void}
     */
    aggregateMenuHide()
    {
        if (this._shellVersion >= 43) {
            return;
        }

        this._main.panel.statusArea['aggregateMenu'].container.hide();
    }

    /**
     * set 'enableHotCorners' original value
     *
     * @returns {void}
     */
    _setEnableHotCornersOriginal()
    {
        if (this._originals['enableHotCorners'] !== undefined) {
            return;
        }

        this._originals['enableHotCorners']
        = this._interfaceSettings.get_boolean('enable-hot-corners');
    }

    /**
     * enable hot corners
     *
     * @returns {void}
     */
    hotCornersEnable()
    {
        this._setEnableHotCornersOriginal();
        this._interfaceSettings.set_boolean('enable-hot-corners', true);
    }

    /**
     * disable hot corners
     *
     * @returns {void}
     */
    hotCornersDisable()
    {
        this._setEnableHotCornersOriginal();
        this._interfaceSettings.set_boolean('enable-hot-corners', false);
    }

    /**
     * set the hot corners to default value
     *
     * @returns {void}
     */
    hotCornersDefault()
    {
        this._setEnableHotCornersOriginal();

        this._interfaceSettings.set_boolean('enable-hot-corners',
            this._originals['enableHotCorners']);
    }

    /**
     * check whether lock dialog is currently showing
     *
     * @returns {boolean}
     */
    isLocked()
    {
        return this._main.sessionMode.isLocked;
    }

    /**
     * enable window picker icon
     *
     * @returns {void}
     */
    windowPickerIconEnable()
    {
        if (this._shellVersion < 40) {
            return;
        }

        this.UIStyleClassRemove(this._getAPIClassname('no-window-picker-icon'));
    }

    /**
     * disable window picker icon
     *
     * @returns {void}
     */
    windowPickerIconDisable()
    {
        if (this._shellVersion < 40) {
            return;
        }

        this.UIStyleClassAdd(this._getAPIClassname('no-window-picker-icon'));
    }

    /**
     * show power icon
     *
     * @returns {void}
     */
    powerIconShow()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-power-icon'));
    }

    /**
     * hide power icon
     *
     * @returns {void}
     */
    powerIconHide()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-power-icon'));
    }

    /**
     * get primary monitor information
     *
     * @returns {false|Object} false when monitor does not exist | object
     *  x: int
     *  y: int
     *  width: int
     *  height: int
     *  geometryScale: float
     */
    monitorGetInfo()
    {
        let pMonitor = this._main.layoutManager.primaryMonitor;

        if (!pMonitor) {
            return false;
        }

        return {
            'x': pMonitor.x,
            'y': pMonitor.y,
            'width': pMonitor.width,
            'height': pMonitor.height,
            'geometryScale': pMonitor.geometry_scale,
        };
    }

    /**
     * get panel position
     *
     * @returns {number} see PANEL_POSITION
     */
    panelGetPosition()
    {
        if (this._panelPosition === undefined) {
            return PANEL_POSITION.TOP;
        }

        return this._panelPosition;
    }

    /**
     * move panel position
     *
     * @param {number} position see PANEL_POSITION
     * @param {boolean} force allow to set even when the current position
     *   is the same
     *
     * @returns {void}
     */
    panelSetPosition(position, force = false)
    {
        let monitorInfo = this.monitorGetInfo();
        let panelBox = this._main.layoutManager.panelBox;

        if (!force && position === this.panelGetPosition()) {
            return;
        }

        if (position === PANEL_POSITION.TOP) {
            this._panelPosition = PANEL_POSITION.TOP;
            if (this._workareasChangedSignal) {
                global.display.disconnect(this._workareasChangedSignal);
                this._workareasChangedSignal = null;
            }
            let topX = (monitorInfo) ? monitorInfo.x : 0;
            let topY = (monitorInfo) ? monitorInfo.y : 0;
            panelBox.set_position(topX, topY);
            this.UIStyleClassRemove(this._getAPIClassname('bottom-panel'));
            this._emitPanelPositionChanged(true);
            return;
        }

        this._panelPosition = PANEL_POSITION.BOTTOM;

        // only change it when a monitor detected
        // 'workareas-changed' signal will do the job on next monitor detection
        if (monitorInfo) {
            let BottomX = monitorInfo.x;
            let BottomY = monitorInfo.y + monitorInfo.height - this.panelGetSize();

            panelBox.set_position(BottomX, BottomY);
            this.UIStyleClassAdd(this._getAPIClassname('bottom-panel'));
        }

        if (!this._workareasChangedSignal) {
            this._workareasChangedSignal
            = global.display.connect('workareas-changed', () => {
                this.panelSetPosition(PANEL_POSITION.BOTTOM, true);
            });
        }

        this._emitPanelPositionChanged(true);
    }

    /**
     * fix looking glass position
     *
     * @returns {void}
     */
    _fixLookingGlassPosition()
    {
        let lookingGlassProto = this._lookingGlass.LookingGlass.prototype;

        if (this._originals['lookingGlassResize'] === undefined) {
            this._originals['lookingGlassResize'] = lookingGlassProto._resize;
        }

        if (this.panelGetPosition() === PANEL_POSITION.TOP && this.isPanelVisible()) {

            lookingGlassProto._resize = this._originals['lookingGlassResize'];
            delete(lookingGlassProto._oldResize);
            delete(this._originals['lookingGlassResize']);
            if (this._main.lookingGlass) {
                this._main.lookingGlass._resize();
            }

            return;
        }

        if (lookingGlassProto._oldResize === undefined) {
            lookingGlassProto._oldResize = this._originals['lookingGlassResize'];

            const Main = this._main;

            lookingGlassProto._resize = function () {
                let panelHeight = Main.layoutManager.panelBox.height;
                this._oldResize();
                this._targetY -= panelHeight;
                this._hiddenY -= panelHeight;
            };
        }
    }

    /**
     * enable panel arrow
     *
     * @returns {void}
     */
    panelArrowEnable()
    {
        if (this._shellVersion >= 40) {
            return;
        }

        this.UIStyleClassRemove(this._getAPIClassname('no-panel-arrow'));
    }

    /**
     * disable panel arrow
     *
     * @returns {void}
     */
    panelArrowDisable()
    {
        if (this._shellVersion >= 40) {
            return;
        }

        this.UIStyleClassAdd(this._getAPIClassname('no-panel-arrow'));
    }

    /**
     * enable panel notification icon
     *
     * @returns {void}
     */
    panelNotificationIconEnable()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-panel-notification-icon'));
    }

    /**
     * disable panel notification icon
     *
     * @returns {void}
     */
    panelNotificationIconDisable()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-panel-notification-icon'));
    }

    /**
     * disable app menu icon
     *
     * @returns {void}
     */
    appMenuIconEnable()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-app-menu-icon'));
    }

    /**
     * disable app menu icon
     *
     * @returns {void}
     */
    appMenuIconDisable()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-app-menu-icon'));
    }

    /**
     * disable app menu label
     *
     * @returns {void}
     */
     appMenuLabelEnable()
     {
         this.UIStyleClassRemove(this._getAPIClassname('no-app-menu-label'));
     }
 
     /**
      * disable app menu label
      *
      * @returns {void}
      */
     appMenuLabelDisable()
     {
         this.UIStyleClassAdd(this._getAPIClassname('no-app-menu-label'));
     }

    /**
     * set the clock menu position
     *
     * @param {number} pos see PANEL_BOX_POSITION
     * @param {number} offset starts from 0 
     *
     * @returns {void}
     */
    clockMenuPositionSet(pos, offset)
    {
        let dateMenu = this._main.panel.statusArea['dateMenu'];

        let panelBoxs = [
            this._main.panel._centerBox,
            this._main.panel._rightBox,
            this._main.panel._leftBox,
        ];

        let fromPos = -1;
        let fromIndex = -1;
        let toIndex = -1;
        let childLength = 0;
        for (let i = 0; i <= 2; i++) {
            let child = panelBoxs[i].get_children();
            let childIndex = child.indexOf(dateMenu.container);
            if (childIndex !== -1) {
                fromPos = i;
                fromIndex = childIndex;
                childLength = panelBoxs[pos].get_children().length;
                toIndex = (offset > childLength) ? childLength : offset;
                break;
            }
        }

        // couldn't find the from and to position because it has been removed
        if (fromPos === -1 || fromIndex === -1 || toIndex === -1) {
            return;
        }

        if (pos === fromPos && toIndex === fromIndex) {
            return;
        }

        panelBoxs[fromPos].remove_actor(dateMenu.container);
        panelBoxs[pos].insert_child_at_index(dateMenu.container, toIndex);

        if (this.isLocked()) {
            this.dateMenuHide();
        }
    }

    /**
     * enable show apps button
     *
     * @returns {void}
     */
    showAppsButtonEnable()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-show-apps-button'));
    }

    /**
     * disable show apps button
     *
     * @returns {void}
     */
    showAppsButtonDisable()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-show-apps-button'));
    }

    /**
     * set animation speed as default
     *
     * @returns {void}
     */
    animationSpeedSetDefault()
    {
        if (this._originals['StSlowDownFactor'] === undefined) {
            return;
        }

        this._st.Settings.get().slow_down_factor = this._originals['StSlowDownFactor'];
    }

    /**
     * change animation speed
     *
     * @param {number} factor in float. bigger number means slower
     *
     * @returns {void}
     */
    animationSpeedSet(factor)
    {
        if (this._originals['StSlowDownFactor'] === undefined) {
            this._originals['StSlowDownFactor']
            = this._st.Settings.get().slow_down_factor;
        }

        this._st.Settings.get().slow_down_factor = factor;
    }

    /**
     * set the enable animation as default
     *
     * @returns {void}
     */
    enableAnimationsSetDefault()
    {
        if (this._originals['enableAnimations'] === undefined) {
            return;
        }

        let status = this._originals['enableAnimations'];

        this._interfaceSettings.set_boolean('enable-animations', status);
    }

    /**
     * set the enable animation status
     *
     * @param {boolean} status true to enable, false otherwise
     *
     * @returns {void}
     */
    enableAnimationsSet(status)
    {
        if (this._originals['enableAnimations'] ===  undefined) {
            this._originals['enableAnimations']
            = this._interfaceSettings.get_boolean('enable-animations');
        }

        this._interfaceSettings.set_boolean('enable-animations', status);
    }

    /**
     * add icon to the activities button
     *
     * @param {number} type see ICON_TYPE
     * @param {string} icon file URI or icon name 
     * @param {boolean} monochrome to show icon in monochrome
     * @param {boolean} holdLabel whether label should be available
     *
     * @returns {void}
     */
    activitiesButtonAddIcon(type, icon, monochrome, holdLabel)
    {
        let iconSize = this.panelIconGetSize() - this._panel.APP_MENU_ICON_MARGIN;
        let activities = this._main.panel.statusArea['activities'];

        this.activitiesButtonRemoveIcon();

        if (!this._activitiesBtn) { 
            this._activitiesBtn = {};
        }

        let iconClassname
        = (monochrome)
        ? this._getAPIClassname('activities-button-icon-monochrome')
        : this._getAPIClassname('activities-button-icon');

        this._activitiesBtn.icon = new this._st.Icon({
            icon_size: iconSize,
            style_class: iconClassname,
            y_align: this._clutter.ActorAlign.CENTER,
        });

        if (monochrome) {
            let effect = new this._clutter.DesaturateEffect();
            this._activitiesBtn.icon.add_effect(effect);

            this._activitiesBtn.icon.connect('style-changed', () => {
                let themeNode = this._activitiesBtn.icon.get_theme_node();
                effect.enabled
                = themeNode.get_icon_style() == this._st.IconStyle.SYMBOLIC;
            });
        }

        switch (type) {

            case ICON_TYPE.NAME:
                if (!icon) {
                    return;
                }
                this._activitiesBtn.icon.set_icon_name(icon);
                break;

            case ICON_TYPE.URI:
                let file = this._gio.File.new_for_uri(icon);
                let filePathExists = file.query_exists(null);
                if (!filePathExists) {
                    return;
                }
                let gicon = this._gio.icon_new_for_string(file.get_path());
                this._activitiesBtn.icon.set_gicon(gicon);
                break;

            default:
                return;
        }

        activities.remove_actor(activities.label_actor);

        // add as icon
        if (!holdLabel) {
            this.UIStyleClassAdd(this._getAPIClassname('activities-button-no-label'));
            activities.add_actor(this._activitiesBtn.icon);
            return;
        }

        // add as container (icon and text)
        this._activitiesBtn.container = new this._st.BoxLayout();
        this._activitiesBtn.container.add_actor(this._activitiesBtn.icon);
        this._activitiesBtn.container.add_actor(activities.label_actor);

        activities.add_actor(this._activitiesBtn.container);
    }

    /**
     * remove icon from activities button if it has been added before
     *
     * @returns {void}
     */
    activitiesButtonRemoveIcon()
    {
        let activities = this._main.panel.statusArea['activities'];

        if (!this._activitiesBtn) {
            return;
        }

        if (this._activitiesBtn.container) {
            this._activitiesBtn.container.remove_actor(this._activitiesBtn.icon);
            this._activitiesBtn.container.remove_actor(activities.label_actor);
            activities.remove_actor(this._activitiesBtn.container);
            this._activitiesBtn.icon = null;
            this._activitiesBtn.container = null;
        }

        if (this._activitiesBtn.icon && activities.contains(this._activitiesBtn.icon)) {
            activities.remove_actor(this._activitiesBtn.icon);
            this._activitiesBtn.icon = null;
        }

        if (!activities.contains(activities.label_actor)) {
            activities.add_actor(activities.label_actor);
        }

        this.UIStyleClassRemove(this._getAPIClassname('activities-button-no-label'));
    }

    /**
     * set activities button icon size
     *
     * @param {number} size 1-60
     *
     * @returns {void}
     */
    _activitiesButtonIconSetSize(size)
    {
        if (size < 1 || size > 60) {
            return;
        }

        let activities = this._main.panel.statusArea['activities'];

        if (!this._activitiesBtn || !this._activitiesBtn.icon) {
            return;
        }
        
        this._activitiesBtn.icon.icon_size = size - this._panel.APP_MENU_ICON_MARGIN;
    }

    /**
     * enable focus when window demands attention happens
     *
     * @returns {void}
     */
    windowDemandsAttentionFocusEnable()
    {
        if (this._displayWindowDemandsAttentionSignal) {
            return;
        }

        let display = global.display;

        this._displayWindowDemandsAttentionSignal
        = display.connect('window-demands-attention', (display, window) => {
            if (!window || window.has_focus() || window.is_skip_taskbar()) {
                return;
            }
            this._main.activateWindow(window);
        });

        // since removing '_windowDemandsAttentionId' doesn't have any effect
        // we remove the original signal and re-connect it on disable
        let signalId
        = (this._shellVersion < 42)
        ? this._main.windowAttentionHandler._windowDemandsAttentionId
        : this._getSignalId(global.display, 'window-demands-attention');

        display.disconnect(signalId);
    }

    /**
     * disable focus when window demands attention happens
     *
     * @returns {void}
     */
    windowDemandsAttentionFocusDisable()
    {
        if (!this._displayWindowDemandsAttentionSignal) {
            return;
        }

        let display = global.display;

        display.disconnect(this._displayWindowDemandsAttentionSignal);
        this._displayWindowDemandsAttentionSignal = null;

        let wah = this._main.windowAttentionHandler;
        wah._windowDemandsAttentionId = display.connect('window-demands-attention',
            wah._onWindowDemandsAttention.bind(wah));
    }

    /**
     * set startup status
     *
     * @param {number} status see SHELL_STATUS for available status
     *
     * @returns {void}
     */
    startupStatusSet(status)
    {
        if (this._shellVersion < 40) {
            return;
        }

        if (!this._main.layoutManager._startingUp) {
            return;
        }

        if (this._originals['sessionModeHasOverview'] === undefined) {
            this._originals['sessionModeHasOverview']
            = this._main.sessionMode.hasOverview;
        }

        let ControlsState = this._overviewControls.ControlsState;
        let Controls = this._main.overview._overview.controls;

        switch (status) {

            case SHELL_STATUS.NONE:
                this._main.sessionMode.hasOverview = false;
                this._main.layoutManager.startInOverview = false;
                Controls._stateAdjustment.value = ControlsState.HIDDEN;
                break;

            case SHELL_STATUS.OVERVIEW:
                this._main.sessionMode.hasOverview = true;
                this._main.layoutManager.startInOverview = true;
                break;
        }

        if (!this._startupCompleteSignal) {
            this._startupCompleteSignal
            = this._main.layoutManager.connect('startup-complete', () => {
                this._main.sessionMode.hasOverview
                = this._originals['sessionModeHasOverview'];
            });
        }
    }

    /**
     * set startup status to default
     *
     * @returns {void}
     */
    startupStatusSetDefault()
    {
        if (this._originals['sessionModeHasOverview'] === undefined) {
            return;
        }

        if (this._startupCompleteSignal) {
            this._main.layoutManager.disconnect(this._startupCompleteSignal);
        }
    }

    /**
     * set dash icon size to default
     *
     * @returns {void}
     */
    dashIconSizeSetDefault()
    {
        let classnameStarter = this._getAPIClassname('dash-icon-size');

        DASH_ICON_SIZES.forEach(size => {
            this.UIStyleClassRemove(classnameStarter + size);
        });
    }

    /**
     * set dash icon size
     *
     * @param {number} size in pixels
     *   see DASH_ICON_SIZES for available sizes
     *
     * @returns {void}
     */
    dashIconSizeSet(size)
    {
        this.dashIconSizeSetDefault();

        if (!DASH_ICON_SIZES.includes(size)) {
            return;
        }

        let classnameStarter = this._getAPIClassname('dash-icon-size');

        this.UIStyleClassAdd(classnameStarter + size);
    }

    /**
     * disable workspaces in app grid
     *
     * @returns {void}
     */
    workspacesInAppGridDisable()
    {
        if (this._shellVersion < 40) {
            return;
        }

        if (!this._originals['computeWorkspacesBoxForState']) {
            let ControlsManagerLayout = this._overviewControls.ControlsManagerLayout;
            this._originals['computeWorkspacesBoxForState']
            = ControlsManagerLayout.prototype._computeWorkspacesBoxForState;
        }

        let controlsLayout = this._main.overview._overview._controls.layout_manager;

        controlsLayout._computeWorkspacesBoxForState = (state, ...args) => {

            let box = this._originals['computeWorkspacesBoxForState'].call(
                controlsLayout, state, ...args);

            if (state === this._overviewControls.ControlsState.APP_GRID) {
                box.set_size(box.get_width(), 0);
            }

            return box;
        };
    }

    /**
     * enable workspaces in app grid
     *
     * @returns {void}
     */
    workspacesInAppGridEnable()
    {
        if (!this._originals['computeWorkspacesBoxForState']) {
            return;
        }

        let controlsLayout = this._main.overview._overview._controls.layout_manager;

        controlsLayout._computeWorkspacesBoxForState
        = this._originals['computeWorkspacesBoxForState'];
    }

    /**
     * change notification banner position
     *
     * @param {number} pos
     *   see XY_POSITION for available positions
     *
     * @returns {void}
     */
    notificationBannerPositionSet(pos)
    {
        let messageTray = this._main.messageTray;
        let bannerBin = messageTray._bannerBin;

        if (this._originals['bannerAlignmentX'] === undefined) {
            this._originals['bannerAlignmentX'] = messageTray.bannerAlignment;
        }

        if (this._originals['bannerAlignmentY'] === undefined) {
            this._originals['bannerAlignmentY'] = bannerBin.get_y_align();
        }

        if (this._originals['hideNotification'] === undefined) {
            this._originals['hideNotification'] = messageTray._hideNotification;
        }

        // TOP
        messageTray._hideNotification = this._originals['hideNotification'];

        bannerBin.set_y_align(this._clutter.ActorAlign.START);

        if (pos === XY_POSITION.TOP_START) {
            messageTray.bannerAlignment = this._clutter.ActorAlign.START;
            return;
        }

        if (pos === XY_POSITION.TOP_END) {
            messageTray.bannerAlignment = this._clutter.ActorAlign.END;
            return;
        }

        if (pos === XY_POSITION.TOP_CENTER) {
            messageTray.bannerAlignment = this._clutter.ActorAlign.CENTER;
            return;
        }

        // BOTTOM

        // >>
        // This block is going to fix the animation when the notification is
        // in bottom area
        // this is the same function from (ui.messageTray.messageTray._hideNotification)
        // with clutter animation mode set to EASE.
        // because the EASE_OUT_BACK (original code) causes glitch when
        // the tray is on bottom 
        const State = this._messageTray.State;
        const ANIMATION_TIME = this._messageTray.ANIMATION_TIME;
        const Clutter = this._clutter;
        const SHELL_VERSION = this._shellVersion;

        messageTray._hideNotification = function (animate) {
            this._notificationFocusGrabber.ungrabFocus();

            if (SHELL_VERSION >= 42) {
                this._banner.disconnectObject(this);
            } else {
                if (this._bannerClickedId) {
                    this._banner.disconnect(this._bannerClickedId);
                    this._bannerClickedId = 0;
                }
                if (this._bannerUnfocusedId) {
                    this._banner.disconnect(this._bannerUnfocusedId);
                    this._bannerUnfocusedId = 0;
                }
            }

            this._resetNotificationLeftTimeout();
            this._bannerBin.remove_all_transitions();

            if (animate) {
                this._notificationState = State.HIDING;
                this._bannerBin.ease({
                    opacity: 0,
                    duration: ANIMATION_TIME,
                    mode: Clutter.AnimationMode.EASE,
                });
                this._bannerBin.ease({
                    opacity: 0,
                    y: this._bannerBin.height,
                    duration: ANIMATION_TIME,
                    mode: Clutter.AnimationMode.EASE,
                    onComplete: () => {
                        this._notificationState = State.HIDDEN;
                        this._hideNotificationCompleted();
                        this._updateState();
                    },
                });
            } else {
                this._bannerBin.y = this._bannerBin.height;
                this._bannerBin.opacity = 0;
                this._notificationState = State.HIDDEN;
                this._hideNotificationCompleted();
            }
        }
        // <<

        bannerBin.set_y_align(this._clutter.ActorAlign.END);

        if (pos === XY_POSITION.BOTTOM_START) {
            messageTray.bannerAlignment = this._clutter.ActorAlign.START;
            return;
        }

        if (pos === XY_POSITION.BOTTOM_END) {
            messageTray.bannerAlignment = this._clutter.ActorAlign.END;
            return;
        }

        if (pos === XY_POSITION.BOTTOM_CENTER) {
            messageTray.bannerAlignment = this._clutter.ActorAlign.CENTER;
            return;
        }
    }

    /**
     * set notification banner position to default position
     *
     * @returns {void}
     */
    notificationBannerPositionSetDefault()
    {
        if (this._originals['bannerAlignmentX'] === undefined ||
            this._originals['bannerAlignmentY'] === undefined ||
            this._originals['hideNotification'] === undefined
        ) {
            return;
        }

        let messageTray = this._main.messageTray;
        let bannerBin = messageTray._bannerBin;

        messageTray.bannerAlignment = this._originals['bannerAlignmentX'];
        bannerBin.set_y_align(this._originals['bannerAlignmentY']);
        messageTray._hideNotification = this._originals['hideNotification'];
    }

    /**
     * set the workspace switcher to always/never show
     *
     * @param {boolean} show true for always show, false for never show
     *
     * @returns {void}
     */
    workspaceSwitcherShouldShow(shouldShow = true)
    {
        if (this._shellVersion < 40) {
            return;
        }

        let ThumbnailsBoxProto = this._workspaceThumbnail.ThumbnailsBox.prototype;

        if (!this._originals['updateShouldShow']) {
            this._originals['updateShouldShow'] = ThumbnailsBoxProto._updateShouldShow;
        }

        ThumbnailsBoxProto._updateShouldShow = function () {
            if (this._shouldShow === shouldShow) {
                return;
            }
            this._shouldShow = shouldShow;
            this.notify('should-show');
        };
    }

    /**
     * set the always show workspace switcher status to default
     *
     * @returns {void}
     */
    workspaceSwitcherShouldShowSetDefault()
    {
        if (!this._originals['updateShouldShow']) {
            return;
        }

        let ThumbnailsBoxProto = this._workspaceThumbnail.ThumbnailsBox.prototype;
        ThumbnailsBoxProto._updateShouldShow = this._originals['updateShouldShow'];
    }

    /**
     * set panel button hpadding to default
     *
     * @returns {void}
     */
    panelButtonHpaddingSetDefault()
    {
        if (this._panelButtonHpaddingSize === undefined) {
            return;
        }

        let classnameStarter = this._getAPIClassname('panel-button-padding-size');
        this.UIStyleClassRemove(classnameStarter + this._panelButtonHpaddingSize);
        this._emitRefreshStyles();

        delete this._panelButtonHpaddingSize;
    }

    /**
     * set panel button hpadding size
     *
     * @param {number} size in pixels (0 - 60)
     *
     * @returns {void}
     */
    panelButtonHpaddingSizeSet(size)
    {
        this.panelButtonHpaddingSetDefault();

        if (size < 0 || size > 60) {
            return;
        }

        this._panelButtonHpaddingSize = size;

        let classnameStarter = this._getAPIClassname('panel-button-padding-size');
        this.UIStyleClassAdd(classnameStarter + size);
        this._emitRefreshStyles();
    }

    /**
     * set panel indicator padding to default
     *
     * @returns {void}
     */
    panelIndicatorPaddingSetDefault()
    {
        if (this._panelIndicatorPaddingSize === undefined) {
            return;
        }

        let classnameStarter = this._getAPIClassname('panel-indicator-padding-size');
        this.UIStyleClassRemove(classnameStarter + this._panelIndicatorPaddingSize);
        this._emitRefreshStyles();

        delete this._panelIndicatorPaddingSize;
    }

    /**
     * set panel indicator padding size
     *
     * @param {number} size in pixels (0 - 60)
     *
     * @returns {void}
     */
    panelIndicatorPaddingSizeSet(size)
    {
        this.panelIndicatorPaddingSetDefault();

        if (size < 0 || size > 60) {
            return;
        }

        this._panelIndicatorPaddingSize = size;

        let classnameStarter = this._getAPIClassname('panel-indicator-padding-size');
        this.UIStyleClassAdd(classnameStarter + size);
        this._emitRefreshStyles();
    }

    /**
     * get window preview prototype
     *
     * @returns {Object}
     */
    _windowPreviewGetPrototype()
    {
        if (this._shellVersion <= 3.36) {
            return this._workspace.WindowOverlay.prototype;
        }

        return this._windowPreview.WindowPreview.prototype;
    }

    /**
     * enable window preview caption
     *
     * @returns {void}
     */
    windowPreviewCaptionEnable()
    {
        if (!this._originals['windowPreviewGetCaption']) {
            return;
        }

        let windowPreviewProto = this._windowPreviewGetPrototype();
        windowPreviewProto._getCaption = this._originals['windowPreviewGetCaption'];

        this.UIStyleClassRemove(this._getAPIClassname('no-window-caption'));
    }

    /**
     * disable window preview caption
     *
     * @returns {void}
     */
    windowPreviewCaptionDisable()
    {
        let windowPreviewProto = this._windowPreviewGetPrototype();

        if (!this._originals['windowPreviewGetCaption']) {
            this._originals['windowPreviewGetCaption'] = windowPreviewProto._getCaption;
        }

        windowPreviewProto._getCaption = () => {
            return '';
        };

        this.UIStyleClassAdd(this._getAPIClassname('no-window-caption'));
    }

    /**
     * set workspace background border radius to default size
     *
     * @returns {void}
     */
    workspaceBackgroundRadiusSetDefault()
    {
        if (this._workspaceBackgroundRadiusSize === undefined) {
            return;
        }

        let workspaceBackgroundProto = this._workspace.WorkspaceBackground.prototype;

        workspaceBackgroundProto._updateBorderRadius
        = this._originals['workspaceBackgroundUpdateBorderRadius'];

        let classnameStarter = this._getAPIClassname('workspace-background-radius-size');
        this.UIStyleClassRemove(classnameStarter + this._workspaceBackgroundRadiusSize);

        delete this._workspaceBackgroundRadiusSize;
    }

    /**
     * set workspace background border radius size
     *
     * @param {number} size in pixels (0 - 60)
     *
     * @returns {void}
     */
    workspaceBackgroundRadiusSet(size)
    {
        if (this._shellVersion < 40) {
            return;
        }

        if (size < 0 || size > 60) {
            return;
        }

        this.workspaceBackgroundRadiusSetDefault();

        let workspaceBackgroundProto = this._workspace.WorkspaceBackground.prototype;

        if (!this._originals['workspaceBackgroundUpdateBorderRadius']) {
            this._originals['workspaceBackgroundUpdateBorderRadius']
            = workspaceBackgroundProto._updateBorderRadius;
        }

        const Util = this._util;
        const St = this._st;

        workspaceBackgroundProto._updateBorderRadius = function () {
            const {scaleFactor} = St.ThemeContext.get_for_stage(global.stage);
            const cornerRadius = scaleFactor * size;

            const backgroundContent = this._bgManager.backgroundActor.content;
            backgroundContent.rounded_clip_radius = 
                Util.lerp(0, cornerRadius, this._stateAdjustment.value);
        }

        this._workspaceBackgroundRadiusSize = size;

        let classnameStarter = this._getAPIClassname('workspace-background-radius-size');
        this.UIStyleClassAdd(classnameStarter + size);
    }

    /**
     * enable workspace wraparound
     *
     * @returns {void}
     */
    workspaceWraparoundEnable()
    {
        let metaWorkspaceProto = this._meta.Workspace.prototype;

        if (!this._originals['metaWorkspaceGetNeighbor']) {
            this._originals['metaWorkspaceGetNeighbor']
            = metaWorkspaceProto.get_neighbor;
        }

        const Meta = this._meta;

        metaWorkspaceProto.get_neighbor = function (dir) {

            let index = this.index();
            let lastIndex = global.workspace_manager.n_workspaces - 1;
            let neighborIndex;

            if (dir === Meta.MotionDirection.UP || dir === Meta.MotionDirection.LEFT) {
                // prev
                neighborIndex = (index > 0) ? index - 1 : lastIndex;
            } else {
                // next
                neighborIndex = (index < lastIndex) ? index + 1 : 0;
            }

            return global.workspace_manager.get_workspace_by_index(neighborIndex);
        };
    }

    /**
     * disable workspace wraparound
     *
     * @returns {void}
     */
    workspaceWraparoundDisable()
    {
        if (!this._originals['metaWorkspaceGetNeighbor']) {
            return;
        }

        let metaWorkspaceProto = this._meta.Workspace.prototype;
        metaWorkspaceProto.get_neighbor = this._originals['metaWorkspaceGetNeighbor'];
    }

    /**
     * enable window preview close button
     *
     * @returns {void}
     */
    windowPreviewCloseButtonEnable()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-window-close'));
    }

    /**
     * disable window preview close button
     *
     * @returns {void}
     */
    windowPreviewCloseButtonDisable()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-window-close'));
    }

    /**
     * enable ripple box
     *
     * @returns {void}
     */
    rippleBoxEnable()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-ripple-box'));
    }

    /**
     * disable ripple box
     *
     * @returns {void}
     */
    rippleBoxDisable()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-ripple-box'));
    }

    /**
     * enable double super press to toggle app grid
     *
     * @returns {void}
     */
    doubleSuperToAppGridEnable()
    {
        if (this._shellVersion < 40 || this._isDoubleSuperToAppGrid === true) {
            return;
        }

        if (!this._overlayKeyNewSignalId) {
            return;
        }

        global.display.disconnect(this._overlayKeyNewSignalId);

        this._gobject.signal_handler_unblock(
            global.display,
            this._overlayKeyOldSignalId
        );

        delete(this._overlayKeyNewSignalId);
        delete(this._overlayKeyOldSignalId);

        this._isDoubleSuperToAppGrid = true;
    }

    /**
     * disable double super press to toggle app grid
     *
     * @returns {void}
     */
    doubleSuperToAppGridDisable()
    {
        if (this._shellVersion < 40 || this._isDoubleSuperToAppGrid === false) {
            return;
        }

        this._overlayKeyOldSignalId = this._getSignalId(global.display, 'overlay-key');

        if (!this._overlayKeyOldSignalId) {
            return;
        }

        this._gobject.signal_handler_block(global.display, this._overlayKeyOldSignalId);

        this._overlayKeyNewSignalId = global.display.connect('overlay-key', () => {
            this._main.overview.toggle();
        });

        this._isDoubleSuperToAppGrid = false;
    }

    /**
     * set default OSD position
     *
     * @returns {void}
     */
    osdPositionSetDefault()
    {
        if (this._shellVersion < 42) {
            return;
        }

        if (!this._originals['osdWindowShow']) {
            return;
        }

        let osdWindowProto = this._osdWindow.OsdWindow.prototype;

        osdWindowProto.show = this._originals['osdWindowShow'];

        delete(osdWindowProto._oldShow);
        delete(this._originals['osdWindowShow']);
        
        if (
            this._originals['osdWindowXAlign'] !== undefined && 
            this._originals['osdWindowYAlign'] !== undefined
        ) {
            let osdWindows = this._main.osdWindowManager._osdWindows;
            osdWindows.forEach(osdWindow => {
                osdWindow.x_align = this._originals['osdWindowXAlign'];
                osdWindow.y_align = this._originals['osdWindowYAlign'];
            });
            delete(this._originals['osdWindowXAlign']);
            delete(this._originals['osdWindowYAlign']);
        }

        this.UIStyleClassRemove(this._getAPIClassname('osd-position-top'));
        this.UIStyleClassRemove(this._getAPIClassname('osd-position-bottom'));
        this.UIStyleClassRemove(this._getAPIClassname('osd-position-center'));
    }

    /**
     * set OSD position
     *
     * @param int pos position XY_POSITION
     *
     * @returns {void}
     */
    osdPositionSet(pos)
    {
        if (this._shellVersion < 42) {
            return;
        }

        let osdWindowProto = this._osdWindow.OsdWindow.prototype;

        if (!this._originals['osdWindowShow']) {
            this._originals['osdWindowShow'] = osdWindowProto.show;
        }

        if (
            this._originals['osdWindowXAlign'] === undefined || 
            this._originals['osdWindowYAlign'] === undefined
        ) {
            let osdWindows = this._main.osdWindowManager._osdWindows;
            this._originals['osdWindowXAlign'] = osdWindows[0].x_align;
            this._originals['osdWindowYAlign'] = osdWindows[0].y_align;
        }

        if (osdWindowProto._oldShow === undefined) {
            osdWindowProto._oldShow = this._originals['osdWindowShow'];
        }

        let [xAlign, yAlign] = this._xyAlignGet(pos);
        osdWindowProto.show = function () {
            this.x_align = xAlign;
            this.y_align = yAlign;
            this._oldShow();
        };

        if (
            pos === XY_POSITION.TOP_START ||
            pos === XY_POSITION.TOP_CENTER ||
            pos === XY_POSITION.TOP_END
        ) {
            this.UIStyleClassAdd(this._getAPIClassname('osd-position-top'));
        }
        
        if (
            pos === XY_POSITION.BOTTOM_START ||
            pos === XY_POSITION.BOTTOM_CENTER ||
            pos === XY_POSITION.BOTTOM_END
        ) {
            this.UIStyleClassAdd(this._getAPIClassname('osd-position-bottom'));
        }
        
        if (
            pos === XY_POSITION.CENTER_START ||
            pos === XY_POSITION.CENTER_CENTER ||
            pos === XY_POSITION.CENTER_END
        ) {
            this.UIStyleClassAdd(this._getAPIClassname('osd-position-center'));
        }
    }

    /**
     * show weather in date menu
     *
     * @returns {void}
     */
    weatherShow()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-weather'));
    }

    /**
     * hide weather in date menu
     *
     * @returns {void}
     */
    weatherHide()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-weather'));
    }

    /**
     * show world clocks in date menu
     *
     * @returns {void}
     */
    worldClocksShow()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-world-clocks'));
    }

    /**
     * hide world clocks in date menu
     *
     * @returns {void}
     */
    worldClocksHide()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-world-clocks'));
    }

    /**
     * show events button in date menu
     *
     * @returns {void}
     */
    eventsButtonShow()
    {
        this.UIStyleClassRemove(this._getAPIClassname('no-events-button'));
    }

    /**
     * hide events button in date menu
     *
     * @returns {void}
     */
    eventsButtonHide()
    {
        this.UIStyleClassAdd(this._getAPIClassname('no-events-button'));
    }

    /**
     * show calendar in date menu
     *
     * @returns {void}
     */
    calendarShow()
    {
        this._main.panel.statusArea.dateMenu._calendar.show();
    }

    /**
     * hide calendar in date menu
     *
     * @returns {void}
     */
    calendarHide()
    {
        this._main.panel.statusArea.dateMenu._calendar.hide();
    }

    /**
     * set default panel icon size
     *
     * @returns {void}
     */
    panelIconSetDefaultSize()
    {
        if (this._panelIconSize === undefined || !this._originals['panelIconSize']) {
            return;
        }

        let classnameStarter = this._getAPIClassname('panel-icon-size');
        this.UIStyleClassRemove(classnameStarter + this._panelIconSize);
        this._emitRefreshStyles();

        let defaultSize = this._originals['panelIconSize'];
        this._panel.PANEL_ICON_SIZE = defaultSize;
        this._main.panel.statusArea['dateMenu']._indicator.set_icon_size(defaultSize);
        this._main.panel.statusArea['appMenu']._onIconThemeChanged();
        this._activitiesButtonIconSetSize(defaultSize);

        delete(this._panelIconSize);
    }

    /**
     * set panel icon size
     *
     * @param {number} size 1-60
     *
     * @returns {void}
     */
    panelIconSetSize(size)
    {
        if (size < 1 || size > 60) {
            return;
        }

        if (!this._originals['panelIconSize']) {
            this._originals['panelIconSize'] = this._panel.PANEL_ICON_SIZE;
        }

        let classnameStarter = this._getAPIClassname('panel-icon-size');
        this.UIStyleClassRemove(classnameStarter + this.panelIconGetSize());
        this.UIStyleClassAdd(classnameStarter + size);
        this._emitRefreshStyles();

        this._panel.PANEL_ICON_SIZE = size;
        this._main.panel.statusArea['dateMenu']._indicator.set_icon_size(size);
        this._main.panel.statusArea['appMenu']._onIconThemeChanged();
        this._activitiesButtonIconSetSize(size);

        this._panelIconSize = size;
    }

    /**
     * get panel icon size
     *
     * @returns {void}
     */
    panelIconGetSize()
    {
        if (this._panelIconSize !== undefined) {
            return this._panelIconSize;
        }

        return this._panel.PANEL_ICON_SIZE;
    }

    /**
     * show dash separator
     *
     * @returns {void}
     */
    dashSeparatorShow()
    {
        if (this._shellVersion < 40) {
            return;
        }

        this.UIStyleClassRemove(this._getAPIClassname('no-dash-separator'));
    }

    /**
     * hide dash separator
     *
     * @returns {void}
     */
    dashSeparatorHide()
    {
        if (this._shellVersion < 40) {
            return;
        }

        this.UIStyleClassAdd(this._getAPIClassname('no-dash-separator'));
    }

    /**
     * get looking glass size
     *
     * @returns {array}
     *  width: int
     *  height: int
     */
    _lookingGlassGetSize()
    {
        let lookingGlass = this._main.createLookingGlass();

        return [lookingGlass.width, lookingGlass.height];
    }

    /**
     * set default looking glass size
     *
     * @returns {void}
     */
    lookingGlassSetDefaultSize()
    {
        if (!this._lookingGlassShowSignal) {
            return;
        }

        this._main.lookingGlass.disconnect(this._lookingGlassShowSignal);
        this._main.lookingGlass._resize();

        delete(this._lookingGlassShowSignal);
        delete(this._lookingGlassOriginalSize);
        delete(this._monitorsChangedSignal);
    }

    /**
     * set looking glass size
     *
     * @param {number} width in float
     * @param {number} height in float
     *
     * @returns {void}
     */
    lookingGlassSetSize(width, height)
    {
        let lookingGlass = this._main.createLookingGlass();

        if (!this._lookingGlassOriginalSize) {
            this._lookingGlassOriginalSize = this._lookingGlassGetSize();
        }

        if (this._lookingGlassShowSignal) {
            lookingGlass.disconnect(this._lookingGlassShowSignal);
            delete(this._lookingGlassShowSignal);
        }

        this._lookingGlassShowSignal = lookingGlass.connect('show', () => {
            let [, currentHeight] = this._lookingGlassGetSize();
            let [originalWidth, originalHeight] = this._lookingGlassOriginalSize;

            let monitorInfo = this.monitorGetInfo();

            let dialogWidth
            =   (width !== null)
            ?   monitorInfo.width * width
            :   originalWidth;

            let x = monitorInfo.x + (monitorInfo.width - dialogWidth) / 2;
            lookingGlass.set_x(x);

            let keyboardHeight = this._main.layoutManager.keyboardBox.height;
            let availableHeight = monitorInfo.height - keyboardHeight;
            let dialogHeight
            = (height !== null)
            ? Math.min(monitorInfo.height * height, availableHeight * 0.9)
            : originalHeight;

            let hiddenY = lookingGlass._hiddenY + currentHeight - dialogHeight;
            lookingGlass.set_y(hiddenY);
            lookingGlass._hiddenY = hiddenY;

            lookingGlass.set_size(dialogWidth, dialogHeight);
        });

        if (!this._monitorsChangedSignal) {
            this._monitorsChangedSignal = this._main.layoutManager.connect('monitors-changed',
            () => {
                    this.lookingGlassSetSize(width, height);
            });
        }
    }

    /**
     * show screenshot in window menu
     *
     * @returns {void}
     */
    screenshotInWindowMenuShow()
    {
        if (this._shellVersion < 42) {
            return;
        }

        let windowMenuProto = this._windowMenu.WindowMenu.prototype;

        if (windowMenuProto._oldBuildMenu === undefined) {
            return;
        }

        windowMenuProto._buildMenu = this._originals['WindowMenubuildMenu'];

        delete(windowMenuProto._oldBuildMenu);
    }

    /**
     * hide screenshot in window menu
     *
     * @returns {void}
     */
    screenshotInWindowMenuHide()
    {
        if (this._shellVersion < 42) {
            return;
        }

        let windowMenuProto = this._windowMenu.WindowMenu.prototype;

        if (!this._originals['WindowMenubuildMenu']) {
            this._originals['WindowMenubuildMenu'] = windowMenuProto._buildMenu;
        }

        if (windowMenuProto._oldBuildMenu === undefined) {
            windowMenuProto._oldBuildMenu = this._originals['WindowMenubuildMenu'];
        }

        windowMenuProto._buildMenu = function (window) {
            this._oldBuildMenu(window);
            this.firstMenuItem.hide();
        };
    }

    /**
     * set default alt tab window preview size
     *
     * @returns {void}
     */
    altTabWindowPreviewSetDefaultSize()
    {
        if (!this._originals['altTabWindowPreviewSize']) {
            return;
        }

        this._altTab.WINDOW_PREVIEW_SIZE = this._originals['altTabWindowPreviewSize'];
    }

    /**
     * set alt tab window preview size
     *
     * @param {number} size 1-512
     *
     * @returns {void}
     */
    altTabWindowPreviewSetSize(size)
    {
        if (size < 1 || size > 512) {
            return;
        }

        if (!this._originals['altTabWindowPreviewSize']) {
            this._originals['altTabWindowPreviewSize'] = this._altTab.WINDOW_PREVIEW_SIZE;
        }

        this._altTab.WINDOW_PREVIEW_SIZE = size;
    }

    /**
     * set default alt tab small icon size
     *
     * @returns {void}
     */
    altTabSmallIconSetDefaultSize()
    {
        if (!this._originals['altTabAppIconSizeSmall']) {
            return;
        }

        this._altTab.APP_ICON_SIZE_SMALL = this._originals['altTabAppIconSizeSmall'];
    }

    /**
     * set alt tab small icon size
     *
     * @param {number} size 1-512
     *
     * @returns {void}
     */
    altTabSmallIconSetSize(size)
    {
        if (size < 1 || size > 512) {
            return;
        }

        if (!this._originals['altTabAppIconSizeSmall']) {
            this._originals['altTabAppIconSizeSmall'] = this._altTab.APP_ICON_SIZE_SMALL;
        }

        this._altTab.APP_ICON_SIZE_SMALL = size;
    }

    /**
     * set default alt tab icon size
     *
     * @returns {void}
     */
    altTabIconSetDefaultSize()
    {
        if (!this._originals['altTabAppIconSize']) {
            return;
        }

        this._altTab.APP_ICON_SIZE = this._originals['altTabAppIconSize'];
    }

    /**
     * set alt tab icon size
     *
     * @param {number} size 1-512
     *
     * @returns {void}
     */
    altTabIconSetSize(size)
    {
        if (size < 1 || size > 512) {
            return;
        }

        if (!this._originals['altTabAppIconSize']) {
            this._originals['altTabAppIconSize'] = this._altTab.APP_ICON_SIZE;
        }

        this._altTab.APP_ICON_SIZE = size;
    }
}

