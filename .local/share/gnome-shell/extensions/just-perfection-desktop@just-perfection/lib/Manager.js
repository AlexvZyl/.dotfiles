/**
 * Manager Library
 *
 * @author     Javad Rahmatzadeh <j.rahmatzadeh@gmail.com>
 * @copyright  2020-2022
 * @license    GPL-3.0-only
 */

/**
 * Apply settings to the GNOME Shell
 */
var Manager = class
{
    /**
     * Class Constructor
     *
     * @param {Object} dependencies
     *   'API' instance of lib::API
     *   'Settings' instance of Gio::Settings
     * @param {number} shellVersion float in major.minor format
     */
    constructor(dependencies, shellVersion)
    {
        this._api = dependencies['API'] || null;
        this._settings = dependencies['Settings'] || null;

        this._shellVersion = shellVersion;
    }

    /**
     * register all signals for settings
     *
     * @returns {void}
     */
    registerSettingsSignals()
    {
        this._settings.connect('changed::panel', () => {
            this._applyPanel(false);
        });

        this._settings.connect('changed::panel-in-overview', () => {
            this._applyPanel(false);
        });

        this._settings.connect('changed::search', () => {
            this._applySearch(false);
        });

        this._settings.connect('changed::dash', () => {
            this._applyDash(false);
        });

        this._settings.connect('changed::osd', () => {
            this._applyOSD(false);
        });

        this._settings.connect('changed::workspace-popup', () => {
            this._applyWorkspacePopup(false);
        });

        this._settings.connect('changed::workspace', () => {
            this._applyWorkspace(false);
        });

        this._settings.connect('changed::background-menu', () => {
            this._applyBackgroundMenu(false);
        });

        this._settings.connect('changed::gesture', () => {
            this._applyGesture(false);
        });

        this._settings.connect('changed::hot-corner', () => {
            this._applyHotCorner(false);
        });

        this._settings.connect('changed::theme', () => {
            this._applyTheme(false);
        });

        this._settings.connect('changed::activities-button', () => {
            this._applyActivitiesButton(false);
        });

        this._settings.connect('changed::app-menu', () => {
            this._applyAppMenu(false);
        });

        this._settings.connect('changed::clock-menu', () => {
            this._applyClockMenu(false);
        });

        this._settings.connect('changed::keyboard-layout', () => {
            this._applyKeyboardLayout(false);
        });

        this._settings.connect('changed::accessibility-menu', () => {
            this._applyAccessibilityMenu(false);
        });

        this._settings.connect('changed::aggregate-menu', () => {
            this._applyAggregateMenu(false);
        });

        this._settings.connect('changed::quick-settings', () => {
            this._applyQuickSettings(false);
        });

        this._settings.connect('changed::panel-corner-size', () => {
            this._applyPanelCornerSize(false);
        });

        this._settings.connect('changed::window-picker-icon', () => {
            this._applyWindowPickerIcon(false);
        });

        this._settings.connect('changed::type-to-search', () => {
            this._applyTypeToSearch(false);
        });

        this._settings.connect('changed::workspace-switcher-size', () => {
            this._applyWorkspaceSwitcherSize(false);
        });

        this._settings.connect('changed::power-icon', () => {
            this._applyPowerIcon(false);
        });

        this._settings.connect('changed::top-panel-position', () => {
            this._applyTopPanelPosition(false);
        });

        this._settings.connect('changed::panel-arrow', () => {
            this._applyPanelArrow(false);
        });

        this._settings.connect('changed::panel-notification-icon', () => {
            this._applyPanelNotificationIcon(false);
        });

        this._settings.connect('changed::app-menu-icon', () => {
            this._applyAppMenuIcon(false);
        });

        this._settings.connect('changed::app-menu-label', () => {
            this._applyAppMenuLabel(false);
        });

        this._settings.connect('changed::clock-menu-position', () => {
            this._applyClockMenuPosition(false);
        });

        this._settings.connect('changed::clock-menu-position-offset', () => {
            this._applyClockMenuPosition(false);
        });

        this._settings.connect('changed::show-apps-button', () => {
            this._applyShowAppsButton(false);
        });

        this._settings.connect('changed::animation', () => {
            this._applyAnimation(false);
        });

        this._settings.connect('changed::activities-button-icon-path', () => {
            this._applyActivitiesButtonIcon(false);
        });

        this._settings.connect('changed::activities-button-icon-monochrome', () => {
            this._applyActivitiesButtonIcon(false);
        });

        this._settings.connect('changed::activities-button-label', () => {
            this._applyActivitiesButtonIcon(false);
        });

        this._settings.connect('changed::window-demands-attention-focus', () => {
            this._applyWindowDemandsAttentionFocus(false);
        });

        this._settings.connect('changed::dash-icon-size', () => {
            this._applyDashIconSize(false);
        });

        this._settings.connect('changed::startup-status', () => {
            this._applyStartupStatus(false);
        });

        this._settings.connect('changed::workspaces-in-app-grid', () => {
            this._applyWorkspacesInAppGrid(false);
        });

        this._settings.connect('changed::notification-banner-position', () => {
            this._applyNotificationBannerPosition(false);
        });

        this._settings.connect('changed::workspace-switcher-should-show', () => {
            this._applyWorkspaceSwitcherShouldShow(false);
        });

        this._settings.connect('changed::panel-size', () => {
            this._applyPanelSize(false);
        });

        this._settings.connect('changed::panel-button-padding-size', () => {
            this._applyPanelButtonPaddingSize(false);
        });

        this._settings.connect('changed::panel-indicator-padding-size', () => {
            this._applyPanelIndicatorPaddingSize(false);
        });

        this._settings.connect('changed::window-preview-caption', () => {
            this._applyWindowPreviewCaption(false);
        });

        this._settings.connect('changed::window-preview-close-button', () => {
            this._applyWindowPreviewCloseButton(false);
        });

        this._settings.connect('changed::workspace-background-corner-size', () => {
            this._applyWorkspaceBackgroundCornerSize(false);
        });

        this._settings.connect('changed::workspace-wrap-around', () => {
            this._applyWorkspaceWrapAround(false);
        });

        this._settings.connect('changed::ripple-box', () => {
            this._applyRippleBox(false);
        });

        this._settings.connect('changed::double-super-to-appgrid', () => {
            this._applyDoubleSuperToAppgrid(false);
        });

        this._settings.connect('changed::world-clock', () => {
            this._applyWorldClock(false);
        });

        this._settings.connect('changed::weather', () => {
            this._applyWeather(false);
        });

        this._settings.connect('changed::calendar', () => {
            this._applyCalendar(false);
        });

        this._settings.connect('changed::events-button', () => {
            this._applyEventsButton(false);
        });

        this._settings.connect('changed::panel-icon-size', () => {
            this._applyPanelIconSize(false);
        });

        this._settings.connect('changed::dash-separator', () => {
            this._applyDashSeparator(false);
        });

        this._settings.connect('changed::looking-glass-width', () => {
            this._applyLookingGlassSize(false);
        });

        this._settings.connect('changed::looking-glass-height', () => {
            this._applyLookingGlassSize(false);
        });

        this._settings.connect('changed::osd-position', () => {
            this._applyOSDPosition(false);
        });

        this._settings.connect('changed::window-menu-take-screenshot-button', () => {
            this._applyWindowMenuTakeScreenshotButton(false);
        });

        this._settings.connect('changed::alt-tab-window-preview-size', () => {
            this._applyAltTabWindowPreviewSize(false);
        });

        this._settings.connect('changed::alt-tab-small-icon-size', () => {
            this._applyAltTabSmallIconSize(false);
        });

        this._settings.connect('changed::alt-tab-icon-size', () => {
            this._applyAltTabIconSize(false);
        });
    }

    /**
     * apply everything to the GNOME Shell
     *
     * @returns {void}
     */
    applyAll()
    {
        this._applyTheme(false);
        this._applyPanel(false);
        this._applySearch(false);
        this._applyDash(false);
        this._applyOSD(false);
        this._applyWorkspacePopup(false);
        this._applyWorkspace(false);
        this._applyBackgroundMenu(false);
        this._applyGesture(false);
        this._applyHotCorner(false);
        this._applyActivitiesButton(false);
        this._applyAppMenu(false);
        this._applyClockMenu(false);
        this._applyKeyboardLayout(false);
        this._applyAccessibilityMenu(false);
        this._applyAggregateMenu(false);
        this._applyQuickSettings(false);
        this._applyPanelCornerSize(false);
        this._applyWindowPickerIcon(false);
        this._applyTypeToSearch(false);
        this._applyWorkspaceSwitcherSize(false);
        this._applyPowerIcon(false);
        this._applyTopPanelPosition(false);
        this._applyPanelArrow(false);
        this._applyPanelNotificationIcon(false);
        this._applyAppMenuIcon(false);
        this._applyAppMenuLabel(false);
        this._applyClockMenuPosition(false);
        this._applyShowAppsButton(false);
        this._applyAnimation(false);
        this._applyActivitiesButtonIcon(false);
        this._applyWindowDemandsAttentionFocus(false);
        this._applyDashIconSize(false);
        this._applyStartupStatus(false);
        this._applyWorkspacesInAppGrid(false);
        this._applyNotificationBannerPosition(false);
        this._applyWorkspaceSwitcherShouldShow(false);
        this._applyPanelSize(false);
        this._applyPanelButtonPaddingSize(false);
        this._applyPanelIndicatorPaddingSize(false);
        this._applyWindowPreviewCaption(false);
        this._applyWindowPreviewCloseButton(false);
        this._applyWorkspaceBackgroundCornerSize(false);
        this._applyWorkspaceWrapAround(false);
        this._applyRippleBox(false);
        this._applyDoubleSuperToAppgrid(false);
        this._applyWorldClock(false);
        this._applyWeather(false);
        this._applyPanelIconSize(false);
        this._applyEventsButton(false);
        this._applyCalendar(false);
        this._applyDashSeparator(false);
        this._applyLookingGlassSize(false);
        this._applyOSDPosition(false);
        this._applyWindowMenuTakeScreenshotButton(false);
        this._applyAltTabWindowPreviewSize(false);
        this._applyAltTabSmallIconSize(false);
        this._applyAltTabIconSize(false);
    }

    /**
     * revert everything done by this class to the GNOME Shell
     *
     * @returns {void}
     */
    revertAll()
    {
        this._applyTheme(true);
        this._applyPanel(true);
        this._applySearch(true);
        this._applyDash(true);
        this._applyOSD(true);
        this._applyWorkspace(true);
        this._applyWorkspacePopup(true);
        this._applyBackgroundMenu(true);
        this._applyGesture(true);
        this._applyHotCorner(true);
        this._applyActivitiesButton(true);
        this._applyAppMenu(true);
        this._applyClockMenu(true);
        this._applyKeyboardLayout(true);
        this._applyAccessibilityMenu(true);
        this._applyAggregateMenu(true);
        this._applyQuickSettings(true);
        this._applyPanelCornerSize(true);
        this._applyWindowPickerIcon(true);
        this._applyTypeToSearch(true);
        this._applyWorkspaceSwitcherSize(true);
        this._applyPowerIcon(true);
        this._applyTopPanelPosition(true);
        this._applyPanelArrow(true);
        this._applyPanelNotificationIcon(true);
        this._applyAppMenuIcon(true);
        this._applyAppMenuLabel(true);
        this._applyClockMenuPosition(true);
        this._applyShowAppsButton(true);
        this._applyAnimation(true);
        this._applyActivitiesButtonIcon(true);
        this._applyWindowDemandsAttentionFocus(true);
        this._applyDashIconSize(true);
        this._applyStartupStatus(true);
        this._applyWorkspacesInAppGrid(true);
        this._applyNotificationBannerPosition(true);
        this._applyWorkspaceSwitcherShouldShow(true);
        this._applyPanelSize(true);
        this._applyPanelButtonPaddingSize(true);
        this._applyPanelIndicatorPaddingSize(true);
        this._applyWindowPreviewCaption(true);
        this._applyWindowPreviewCloseButton(true);
        this._applyWorkspaceBackgroundCornerSize(true);
        this._applyWorkspaceWrapAround(true);
        this._applyRippleBox(true);
        this._applyDoubleSuperToAppgrid(true);
        this._applyWorldClock(true);
        this._applyWeather(true);
        this._applyPanelIconSize(true);
        this._applyEventsButton(true);
        this._applyCalendar(true);
        this._applyDashSeparator(true);
        this._applyLookingGlassSize(true);
        this._applyOSDPosition(true);
        this._applyWindowMenuTakeScreenshotButton(true);
        this._applyAltTabWindowPreviewSize(true);
        this._applyAltTabSmallIconSize(true);
        this._applyAltTabIconSize(true);
    }

    /**
     * apply panel settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanel(forceOriginal)
    {
        let panel = this._settings.get_boolean('panel');
        let panelInOverview = this._settings.get_boolean('panel-in-overview');

        if (forceOriginal || panel) {
            this._api.panelShow();
        } else {
            let mode = (panelInOverview) ? 1 : 0;
            this._api.panelHide(mode, 0);
        }
    }

    /**
     * apply search settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applySearch(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('search')) {
            this._api.searchEntryShow(false);
        } else {
            this._api.searchEntryHide(false);
        }
    }

    /**
     * apply type to search settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyTypeToSearch(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('type-to-search')) {
            this._api.startSearchEnable();
        } else {
            this._api.startSearchDisable();
        }
    }

    /**
     * apply dash settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyDash(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('dash')) {
            this._api.dashShow();
        } else {
            this._api.dashHide();
        }
    }

    /**
     * apply osd settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyOSD(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('osd')) {
            this._api.OSDEnable();
        } else {
            this._api.OSDDisable();
        }
    }

    /**
     * apply workspace popup settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspacePopup(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('workspace-popup')) {
            this._api.workspacePopupEnable();
        } else {
            this._api.workspacePopupDisable();
        }
    }

    /**
     * apply workspace settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspace(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('workspace')) {
            this._api.workspaceSwitcherShow();
        } else {
            this._api.workspaceSwitcherHide();
        }
    }

    /**
     * apply background menu settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyBackgroundMenu(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('background-menu')) {
            this._api.backgroundMenuEnable();
        } else {
            this._api.backgroundMenuDisable();
        }
    }

    /**
     * apply gesture settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyGesture(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('gesture')) {
            this._api.gestureEnable();
        } else {
            this._api.gestureDisable();
        }
    }

    /**
     * apply hot corner settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyHotCorner(forceOriginal)
    {
        if (this._shellVersion >= 41) {
            return;
        }
    
        if (forceOriginal) {
            this._api.hotCornersDefault();
        } else if (!this._settings.get_boolean('hot-corner')) {
            this._api.hotCornersDisable();
        } else {
            this._api.hotCornersEnable();
        }
    }

    /**
     * apply theme settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyTheme(forceOriginal)
    {
        let className = 'just-perfection';
        let fallbackClassName = 'just-perfection-gnome3';
        let fourtySecondGenClassName = 'just-perfection-gnome4x-2nd-gen';

        if (forceOriginal || !this._settings.get_boolean('theme')) {
            this._api.UIStyleClassRemove(className);
            this._api.UIStyleClassRemove(fallbackClassName);
            this._api.UIStyleClassRemove(fourtySecondGenClassName);
        } else {
            this._api.UIStyleClassAdd(className);
            if (this._shellVersion < 40) {
                this._api.UIStyleClassAdd(fallbackClassName);
            }
            if (this._shellVersion >= 42) {
                this._api.UIStyleClassAdd(fourtySecondGenClassName);
            }
        }
    }

    /**
     * apply activites button settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyActivitiesButton(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('activities-button')) {
            this._api.activitiesButtonShow();
        } else {
            this._api.activitiesButtonHide();
        }
    }

    /**
     * apply app menu settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAppMenu(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('app-menu')) {
            this._api.appMenuShow();
        } else {
            this._api.appMenuHide();
        }
    }

    /**
     * apply clock menu (aka date menu) settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyClockMenu(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('clock-menu')) {
            this._api.dateMenuShow();
        } else {
            this._api.dateMenuHide();
        }
    }

    /**
     * apply keyboard layout settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyKeyboardLayout(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('keyboard-layout')) {
            this._api.keyboardLayoutShow();
        } else {
            this._api.keyboardLayoutHide();
        }
    }

    /**
     * apply accessibility menu settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAccessibilityMenu(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('accessibility-menu')) {
            this._api.accessibilityMenuShow();
        } else {
            this._api.accessibilityMenuHide();
        }
    }

    /**
     * apply aggregate menu settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAggregateMenu(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('aggregate-menu')) {
            this._api.aggregateMenuShow();
        } else {
            this._api.aggregateMenuHide();
        }
    }

    /**
     * apply quick settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyQuickSettings(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('quick-settings')) {
            this._api.quickSettingsMenuShow();
        } else {
            this._api.quickSettingsMenuHide();
        }
    }

    /**
     * apply panel corner size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelCornerSize(forceOriginal)
    {
        let size = this._settings.get_int('panel-corner-size');

        if (forceOriginal || size === 0) {
            this._api.panelCornerSetDefault();
        } else {
            this._api.panelCornerSetSize(size - 1);
        }
    }

    /**
     * apply window picker icon settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWindowPickerIcon(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('window-picker-icon')) {
            this._api.windowPickerIconEnable();
        } else {
            this._api.windowPickerIconDisable();
        }
    }

    /**
     * apply workspace switcher size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspaceSwitcherSize(forceOriginal)
    {
        let size = this._settings.get_int('workspace-switcher-size');

        if (forceOriginal || size === 0) {
            this._api.workspaceSwitcherSetDefaultSize();
        } else {
            this._api.workspaceSwitcherSetSize(size / 100, false);
        }
    }

    /**
     * apply power icon settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPowerIcon(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('power-icon')) {
            this._api.powerIconShow();
        } else {
            this._api.powerIconHide();
        }
    }

    /**
     * apply top panel position settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyTopPanelPosition(forceOriginal)
    {
        if (forceOriginal || this._settings.get_int('top-panel-position') === 0) {
            this._api.panelSetPosition(0);
        } else {
            this._api.panelSetPosition(1);
        }
    }

    /**
     * apply panel arrow settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelArrow(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('panel-arrow')) {
            this._api.panelArrowEnable();
        } else {
            this._api.panelArrowDisable();
        }
    }

    /**
     * apply panel notification icon settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelNotificationIcon(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('panel-notification-icon')) {
            this._api.panelNotificationIconEnable();
        } else {
            this._api.panelNotificationIconDisable();
        }
    }

    /**
     * apply app menu icon settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAppMenuIcon(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('app-menu-icon')) {
            this._api.appMenuIconEnable();
        } else {
            this._api.appMenuIconDisable();
        }
    }

    /**
     * apply app menu label settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAppMenuLabel(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('app-menu-label')) {
            this._api.appMenuLabelEnable();
        } else {
            this._api.appMenuLabelDisable();
        }
    }

    /**
     * apply clock menu position settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyClockMenuPosition(forceOriginal)
    {
        if (forceOriginal) {
            this._api.clockMenuPositionSet(0, 0);
        } else {
            let pos = this._settings.get_int('clock-menu-position');
            let offset = this._settings.get_int('clock-menu-position-offset');
            this._api.clockMenuPositionSet(pos, offset);
        }
    }

    /**
     * apply show apps button settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyShowAppsButton(forceOriginal)
    {
        if (forceOriginal || this._settings.get_boolean('show-apps-button')) {
            this._api.showAppsButtonEnable();
        } else {
            this._api.showAppsButtonDisable();
        }
    }

    /**
     * apply animation settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAnimation(forceOriginal)
    {
        let animation = this._settings.get_int('animation');

        let factors = [
            0.4, // fastest
            0.6, // faster
            0.8, // fast
            1.3, // slow
            1.6, // slower
            2.8, // slowest
        ];

        if (forceOriginal) {
            this._api.animationSpeedSetDefault();
            this._api.enableAnimationsSetDefault();
        } else if (animation === 0) {
            // disabled
            this._api.animationSpeedSetDefault();
            this._api.enableAnimationsSet(false);
        } else if (animation === 1) {
            // default speed
            this._api.animationSpeedSetDefault();
            this._api.enableAnimationsSet(true);
        } else if (factors[animation - 2] !== undefined) {
            // custom speed
            this._api.animationSpeedSet(factors[animation - 2]);
            this._api.enableAnimationsSet(true);
        }
    }

    /**
     * apply show apps button settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyActivitiesButtonIcon(forceOriginal)
    {
        let iconPath = this._settings.get_string('activities-button-icon-path');
        let monochrome = this._settings.get_boolean('activities-button-icon-monochrome');
        let label = this._settings.get_boolean('activities-button-label');

        if (forceOriginal) {
            this._api.activitiesButtonRemoveIcon();
        } else {
            this._api.activitiesButtonAddIcon(1, iconPath, monochrome, label);
        }
    }

    /**
     * apply window demands attention focus settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWindowDemandsAttentionFocus(forceOriginal)
    {
        let focus = this._settings.get_boolean('window-demands-attention-focus');

        if (forceOriginal || !focus) {
            this._api.windowDemandsAttentionFocusDisable();
        } else {
            this._api.windowDemandsAttentionFocusEnable();
        }
    }

    /**
     * apply dash icon size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyDashIconSize(forceOriginal)
    {
        let size = this._settings.get_int('dash-icon-size');

        if (forceOriginal || size === 0) {
            this._api.dashIconSizeSetDefault();
        } else {
            this._api.dashIconSizeSet(size);
        }
    }

    /**
     * apply startup status settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyStartupStatus(forceOriginal)
    {
        let status = this._settings.get_int('startup-status');

        if (forceOriginal) {
            this._api.startupStatusSetDefault();
        } else {
            this._api.startupStatusSet(status);
        }
    }

    /**
     * apply workspaces in app grid status settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspacesInAppGrid(forceOriginal)
    {
        let status = this._settings.get_boolean('workspaces-in-app-grid');

        if (forceOriginal || status) {
            this._api.workspacesInAppGridEnable();
        } else {
            this._api.workspacesInAppGridDisable();
        }
    }

    /**
     * apply notification banner position settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyNotificationBannerPosition(forceOriginal)
    {
        let pos = this._settings.get_int('notification-banner-position');

        if (forceOriginal) {
            this._api.notificationBannerPositionSetDefault();
        } else {
            this._api.notificationBannerPositionSet(pos);
        }
    }

    /**
     * apply workspace switcher should show settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspaceSwitcherShouldShow(forceOriginal)
    {
        let shouldShow = this._settings.get_boolean('workspace-switcher-should-show');

        if (forceOriginal || !shouldShow) {
            this._api.workspaceSwitcherShouldShowSetDefault();
        } else {
            this._api.workspaceSwitcherShouldShow(true);
        }
    }

    /**
     * apply panel size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelSize(forceOriginal)
    {
        let size = this._settings.get_int('panel-size');

        if (forceOriginal || size === 0) {
            this._api.panelSetDefaultSize();
        } else {
            this._api.panelSetSize(size, false);
        }
    }

    /**
     * apply panel button padding size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelButtonPaddingSize(forceOriginal)
    {
        let size = this._settings.get_int('panel-button-padding-size');

        if (forceOriginal || size === 0) {
            this._api.panelButtonHpaddingSetDefault();
        } else {
            this._api.panelButtonHpaddingSizeSet(size - 1);
        }
    }

    /**
     * apply panel indicator padding size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelIndicatorPaddingSize(forceOriginal)
    {
        let size = this._settings.get_int('panel-indicator-padding-size');

        if (forceOriginal || size === 0) {
            this._api.panelIndicatorPaddingSetDefault();
        } else {
            this._api.panelIndicatorPaddingSizeSet(size - 1);
        }
    }

    /**
     * apply window preview caption settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWindowPreviewCaption(forceOriginal)
    {
        let status = this._settings.get_boolean('window-preview-caption');

        if (forceOriginal || status) {
            this._api.windowPreviewCaptionEnable();
        } else {
            this._api.windowPreviewCaptionDisable();
        }
    }

    /**
     * apply window preview close button settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWindowPreviewCloseButton(forceOriginal)
    {
        let status = this._settings.get_boolean('window-preview-close-button');

        if (forceOriginal || status) {
            this._api.windowPreviewCloseButtonEnable();
        } else {
            this._api.windowPreviewCloseButtonDisable();
        }
    }

    /**
     * apply workspace background corner size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspaceBackgroundCornerSize(forceOriginal)
    {
        let size = this._settings.get_int('workspace-background-corner-size');

        if (forceOriginal || size === 0) {
            this._api.workspaceBackgroundRadiusSetDefault();
        } else {
            this._api.workspaceBackgroundRadiusSet(size - 1);
        }
    }

    /**
     * apply workspace wrap around settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorkspaceWrapAround(forceOriginal)
    {
        let status = this._settings.get_boolean('workspace-wrap-around');

        if (forceOriginal || !status) {
            this._api.workspaceWraparoundDisable();
        } else {
            this._api.workspaceWraparoundEnable();
        }
    }
    
    /**
     * apply ripple box settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyRippleBox(forceOriginal)
    {
        let status = this._settings.get_boolean('ripple-box');

        if (forceOriginal || status) {
            this._api.rippleBoxEnable();
        } else {
            this._api.rippleBoxDisable();
        }
    }

    /**
     * apply double super to appgrid settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyDoubleSuperToAppgrid(forceOriginal)
    {
        let status = this._settings.get_boolean('double-super-to-appgrid');

        if (forceOriginal || status) {
            this._api.doubleSuperToAppGridEnable();
        } else {
            this._api.doubleSuperToAppGridDisable();
        }
    }

    /**
     * apply world clock settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWorldClock(forceOriginal)
    {
        let status = this._settings.get_boolean('world-clock');

        if (forceOriginal || status) {
            this._api.worldClocksShow();
        } else {
            this._api.worldClocksHide();
        }
    }

    /**
     * apply weather settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWeather(forceOriginal)
    {
        let status = this._settings.get_boolean('weather');

        if (forceOriginal || status) {
            this._api.weatherShow();
        } else {
            this._api.weatherHide();
        }
    }

    /**
     * apply calendar settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyCalendar(forceOriginal)
    {
        let status = this._settings.get_boolean('calendar');

        if (forceOriginal || status) {
            this._api.calendarShow();
        } else {
            this._api.calendarHide();
        }
    }

    /**
     * apply events button settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyEventsButton(forceOriginal)
    {
        let status = this._settings.get_boolean('events-button');

        if (forceOriginal || status) {
            this._api.eventsButtonShow();
        } else {
            this._api.eventsButtonHide();
        }
    }

    /**
     * apply panel icon size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyPanelIconSize(forceOriginal)
    {
        let size = this._settings.get_int('panel-icon-size');

        if (forceOriginal || size === 0) {
            this._api.panelIconSetDefaultSize();
        } else {
            this._api.panelIconSetSize(size);
        }
    }

    /**
     * apply dash separator settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyDashSeparator(forceOriginal)
    {
        let status = this._settings.get_boolean('dash-separator');

        if (forceOriginal || status) {
            this._api.dashSeparatorShow();
        } else {
            this._api.dashSeparatorHide();
        }
    }

    /**
     * apply looking glass size settings
     * 
     * @param {boolean} forceOriginal force original shell setting
     * 
     * @returns {void}
     */
    _applyLookingGlassSize(forceOriginal)
    {
        let widthSize = this._settings.get_int('looking-glass-width');
        let heightSize = this._settings.get_int('looking-glass-height');

        if (forceOriginal) {
            this._api.lookingGlassSetDefaultSize();
        } else {
            let width = (widthSize !== 0) ? widthSize / 10 : null;
            let height = (heightSize !== 0) ? heightSize / 10 : null;
            this._api.lookingGlassSetSize(width, height);
        }
    }

    /**
     * apply osd position settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyOSDPosition(forceOriginal)
    {
        let pos = this._settings.get_int('osd-position');

        if (forceOriginal || pos === 0) {
            this._api.osdPositionSetDefault();
        } else {
            this._api.osdPositionSet(pos - 1);
        }
    }
    
    /**
     * apply window menu take screenshot button settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyWindowMenuTakeScreenshotButton(forceOriginal)
    {
        let status = this._settings.get_boolean('window-menu-take-screenshot-button');

        if (forceOriginal || status) {
            this._api.screenshotInWindowMenuShow();
        } else {
            this._api.screenshotInWindowMenuHide();
        }
    }

    /**
     * apply alt tab window preview size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAltTabWindowPreviewSize(forceOriginal)
    {
        let size = this._settings.get_int('alt-tab-window-preview-size');

        if (forceOriginal || size === 0) {
            this._api.altTabWindowPreviewSetDefaultSize();
        } else {
            this._api.altTabWindowPreviewSetSize(size);
        }
    }

    /**
     * apply alt tab small icon size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAltTabSmallIconSize(forceOriginal)
    {
        let size = this._settings.get_int('alt-tab-small-icon-size');

        if (forceOriginal || size === 0) {
            this._api.altTabSmallIconSetDefaultSize();
        } else {
            this._api.altTabSmallIconSetSize(size);
        }
    }

    /**
     * apply alt tab icon size settings
     *
     * @param {boolean} forceOriginal force original shell setting
     *
     * @returns {void}
     */
    _applyAltTabIconSize(forceOriginal)
    {
        let size = this._settings.get_int('alt-tab-icon-size');

        if (forceOriginal || size === 0) {
            this._api.altTabIconSetDefaultSize();
        } else {
            this._api.altTabIconSetSize(size);
        }
    }
}

