/**
 * StatusAreaHorizontalSpacing extension
 * v2.1.1
 *
 * This extension essentially modifies the "-natural-hpadding"
 * attribute of panel-buttons (i.e. indicators in the status area)
 * so that they can be closer together.
 *
 * The default is 12.
 *
 * It does this by using 'set_style' to override the '-natural-hpadding'
 * property of anything added to Main.panel._rightBox.
 * It listens to the 'add-actor' signal of Main.panel._rightBox to override
 * the style.
 *
 * 2012 mathematical.coffee@gmail.com
 *
 * v2.0.1:
 * BUGFIX: User menu button resumes normal spacing on clicking/hovering.
 * (panel.js _boxStyleChanged button.style='transition-duration: 0')
 */

/****************************
 * CODE
 ****************************/
const Mainloop = imports.mainloop;
const St = imports.gi.St;
const Shell = imports.gi.Shell;

const Main = imports.ui.main;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

let actorAddedID, hpaddingChangedID, styleLine, padding, settings;

/* Note: the gnome-shell class always overrides any you add in the extension.
 * So doing add_style_class(my_style_with_less_hpadding) doesn't work.
 * However set_style sets the inline style and that works.
 *
 * In GNOME 3.6 the actor with style class 'panel-button' is not the top-level
 * actor; they are all nested into St.Bins.
 *
 * So we have to drill down to find the GenericConainer.
 * However, we only recurse down one level to find the actor with style class
 * 'panel-button' because otherwise we'll spend all day doing it.
 */
function _refreshActor(actor) {
    // thanks to https://github.com/home-sweet-gnome/dash-to-panel/commit/d372e6abd393b8f1c0e791b043dc2283b41d3ffb
    if (imports.misc.config.PACKAGE_VERSION >= '3.34.0') {
	let oldClass = actor.get_style_class_name();
	actor.set_style_class_name('dummy-class-unlikely-to-exist-status-area-horizontal-spacing');
	actor.set_style_class_name(oldClass);
    }
}

function overrideStyle(actor, secondTime) {
    // it could be that the first child has the right style class name.
    if (!actor.has_style_class_name ||
            !actor.has_style_class_name('panel-button')) {
        if (secondTime) {
            // if we've already recursed once, then give up (we will only look
            // one level down to find the 'panel-button' actor).
            return;
        }
        let child = actor.get_children();
        if (child.length) {
            overrideStyle(child[0], true);
        }
        return;
    }

    if (actor._original_inline_style_ === undefined) {
        actor._original_inline_style_ = actor.get_style();
    }
    actor.set_style(styleLine + '; ' + (actor._original_inline_style_ || ''));
    /* listen for the style being set externally so we can re-apply our style */
    // TODO: somehow throttle the number of calls to this - add a timeout with
    // a flag?
    if (!actor._statusAreaHorizontalSpacingSignalID) {
        actor._statusAreaHorizontalSpacingSignalID =
            actor.connect('style-changed', function () {
                let currStyle = actor.get_style();
                if (currStyle && !currStyle.match(styleLine)) {
                    // re-save the style (if it has in fact changed)
                    actor._original_inline_style_ = currStyle;
                    // have to do this or else the overrideStyle call will trigger
                    // another call of this, firing an endless series of these signals.
                    // TODO: a ._style_pending which prevents it rather than disconnect/connect?
                    actor.disconnect(actor._statusAreaHorizontalSpacingSignalID);
                    delete actor._statusAreaHorizontalSpacingSignalID;
                    overrideStyle(actor);
                }
            });
    }
    _refreshActor(actor);
}

// see the note in overrideStyle about us having to recurse down to the first
// child of `actor` in order to find the container with style class name
// 'panel-button' (applying our style to the parent container won't work).
function restoreOriginalStyle(actor, secondTime) {
    if (!actor.has_style_class_name ||
            !actor.has_style_class_name('panel-button')) {
        if (secondTime) {
            // if we've already recursed once, then give up (we will only look
            // one level down to find the 'panel-button' actor).
            return;
        }
        let child = actor.get_children();
        if (child.length) {
            restoreOriginalStyle(child[0], true);
        }
        return;
    }
    if (actor._statusAreaHorizontalSpacingSignalID) {
        actor.disconnect(actor._statusAreaHorizontalSpacingSignalID);
        delete actor._statusAreaHorizontalSpacingSignalID;
    }
    if (actor._original_inline_style_ !== undefined) {
        actor.set_style(actor._original_inline_style_);
        delete actor._original_inline_style_;
    }
    _refreshActor(actor);
}

/* Apply hpadding style to all existing actors & listen for more */
function applyStyles() {
    padding = settings.get_int('hpadding');
    styleLine = '-natural-hpadding: %dpx'.format(padding);
    // if you set it below 6 and it looks funny, that's your fault!
    if (padding < 6) {
        styleLine += '; -minimum-hpadding: %dpx'.format(padding);
    }

    /* set style for everything in _rightBox */
    let children = Main.panel._rightBox.get_children();
    for (let i = 0; i < children.length; ++i) {
        overrideStyle(children[i]);
    }

    /* connect signal */
    actorAddedID = Main.panel._rightBox.connect('actor-added',
        function (container, actor) {
            overrideStyle(actor);
        }
    );
}

/* Remove hpadding style from all existing actors & stop listening for more */
function removeStyles() {
    /* disconnect signal */
    if (actorAddedID) {
        Main.panel._rightBox.disconnect(actorAddedID);
    }
    /* remove style class name. */
    let children = Main.panel._rightBox.get_children();
    for (let i = 0; i < children.length; ++i) {
        restoreOriginalStyle(children[i]);
    }
}

function init(extensionMeta) {
    ExtensionUtils.initTranslations();
}

function enable() {
    settings = ExtensionUtils.getSettings();
    applyStyles();
    /* whenever the settings get changed, re-layout everything. */
    hpaddingChangedID = settings.connect('changed::hpadding', function () {
        removeStyles();
        applyStyles();
    });
}

function disable() {
    /*
     * This extension requires unlock-dialog session-mode because its functionality
     * is useful in lockscreen as well. The rationale is well explained in
     * https://gitlab.com/p91paul/status-area-horizontal-spacing-gnome-shell-extension/-/merge_requests/5
     * Preventing disabling when locking also works around a gnome shell crash.
     */
    removeStyles();
    if (hpaddingChangedID) {
        settings.disconnect(hpaddingChangedID);
    }
    settings = null;
}
