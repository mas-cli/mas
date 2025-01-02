// swift-format-ignore-file
// swiftlint:disable:next blanket_disable_command
// swiftlint:disable attributes discouraged_none_name file_length file_types_order identifier_name
// swiftlint:disable:next blanket_disable_command
// swiftlint:disable implicitly_unwrapped_optional legacy_objc_type line_length missing_docs
import AppKit
import ScriptingBridge

// MARK: FinderEdfm
@objc
public enum FinderEdfm: AEKeyword {
    case macOSFormat = 0x6466_6866 // 'dfhf'
    case macOSExtendedFormat = 0x6466_682b // 'dfh+'
    case ufsFormat = 0x6466_7566 // 'dfuf'
    case nfsFormat = 0x6466_6e66 // 'dfnf'
    case audioFormat = 0x6466_6175 // 'dfau'
    case proDOSFormat = 0x6466_7072 // 'dfpr'
    case msdosFormat = 0x6466_6d73 // 'dfms'
    case ntfsFormat = 0x6466_6e74 // 'dfnt'
    case iso9660Format = 0x6466_3936 // 'df96'
    case highSierraFormat = 0x6466_6873 // 'dfhs'
    case quickTakeFormat = 0x6466_7174 // 'dfqt'
    case applePhotoFormat = 0x6466_7068 // 'dfph'
    case appleShareFormat = 0x6466_6173 // 'dfas'
    case udfFormat = 0x6466_7564 // 'dfud'
    case webDAVFormat = 0x6466_7764 // 'dfwd'
    case ftpFormat = 0x6466_6674 // 'dfft'
    case packetWrittenUDFFormat = 0x6466_7075 // 'dfpu'
    case xsanFormat = 0x6466_6163 // 'dfac'
    case apfsFormat = 0x6466_6170 // 'dfap'
    case exFATFormat = 0x6466_7866 // 'dfxf'
    case smbFormat = 0x6466_736d // 'dfsm'
    case unknownFormat = 0x6466_3f3f // 'df??'
}

// MARK: FinderIpnl
@objc
public enum FinderIpnl: AEKeyword {
    case generalInformationPanel = 0x6770_6e6c // 'gpnl'
    case sharingPanel = 0x7370_6e6c // 'spnl'
    case memoryPanel = 0x6d70_6e6c // 'mpnl'
    case previewPanel = 0x7670_6e6c // 'vpnl'
    case applicationPanel = 0x6170_6e6c // 'apnl'
    case languagesPanel = 0x706b_6c67 // 'pklg'
    case pluginsPanel = 0x706b_7067 // 'pkpg'
    case nameExtensionPanel = 0x6e70_6e6c // 'npnl'
    case commentsPanel = 0x6370_6e6c // 'cpnl'
    case contentIndexPanel = 0x6369_6e6c // 'cinl'
    case burningPanel = 0x6270_6e6c // 'bpnl'
    case moreInfoPanel = 0x6d69_6e6c // 'minl'
    case simpleHeaderPanel = 0x7368_6e6c // 'shnl'
}

// MARK: FinderPple
@objc
public enum FinderPple: AEKeyword {
    case generalPreferencesPanel = 0x7067_6e70 // 'pgnp'
    case labelPreferencesPanel = 0x706c_6270 // 'plbp'
    case sidebarPreferencesPanel = 0x7073_6964 // 'psid'
    case advancedPreferencesPanel = 0x7061_6476 // 'padv'
}

// MARK: FinderPriv
@objc
public enum FinderPriv: AEKeyword {
    case readOnly = 0x7265_6164 // 'read'
    case readWrite = 0x7264_7772 // 'rdwr'
    case writeOnly = 0x7772_6974 // 'writ'
    case none = 0x6e6f_6e65 // 'none'
}

// MARK: FinderEcvw
@objc
public enum FinderEcvw: AEKeyword {
    case iconView = 0x6963_6e76 // 'icnv'
    case listView = 0x6c73_7677 // 'lsvw'
    case columnView = 0x636c_7677 // 'clvw'
    case groupView = 0x6772_7677 // 'grvw'
    case flowView = 0x666c_7677 // 'flvw'
}

// MARK: FinderEarr
@objc
public enum FinderEarr: AEKeyword {
    case notArranged = 0x6e61_7272 // 'narr'
    case snapToGrid = 0x6772_6461 // 'grda'
    case arrangedByName = 0x6e61_6d61 // 'nama'
    case arrangedByModificationDate = 0x6d64_7461 // 'mdta'
    case arrangedByCreationDate = 0x6364_7461 // 'cdta'
    case arrangedBySize = 0x7369_7a61 // 'siza'
    case arrangedByKind = 0x6b69_6e61 // 'kina'
    case arrangedByLabel = 0x6c61_6261 // 'laba'
}

// MARK: FinderEpos
@objc
public enum FinderEpos: AEKeyword {
    case right = 0x6c72_6774 // 'lrgt'
    case bottom = 0x6c62_6f74 // 'lbot'
}

// MARK: FinderSodr
@objc
public enum FinderSodr: AEKeyword {
    case normal = 0x736e_726d // 'snrm'
    case reversed = 0x7372_7673 // 'srvs'
}

// MARK: FinderElsv
@objc
public enum FinderElsv: AEKeyword {
    case nameColumn = 0x656c_736e // 'elsn'
    case modificationDateColumn = 0x656c_736d // 'elsm'
    case creationDateColumn = 0x656c_7363 // 'elsc'
    case sizeColumn = 0x656c_7373 // 'elss'
    case kindColumn = 0x656c_736b // 'elsk'
    case labelColumn = 0x656c_736c // 'elsl'
    case versionColumn = 0x656c_7376 // 'elsv'
    case commentColumn = 0x656c_7343 // 'elsC'
}

// MARK: FinderLvic
@objc
public enum FinderLvic: AEKeyword {
    case smallIcon = 0x736d_6963 // 'smic'
    case largeIcon = 0x6c67_6963 // 'lgic'
}

@objc
public protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> Any!
}

@objc
public protocol SBApplicationProtocol: SBObjectProtocol {
    var delegate: SBApplicationDelegate! { get set }
    var isRunning: Bool { get }

    func activate()
}

// MARK: FinderGenericMethods
@objc
public protocol FinderGenericMethods {
    @objc optional func openUsing(_ using_: SBObject!, withProperties: [AnyHashable: Any]!) // Open the specified object(s)
    @objc optional func printWithProperties(_ withProperties: [AnyHashable: Any]!) // Print the specified object(s)
    @objc optional func activate() // Activate the specified window (or the Finder)
    @objc optional func close() // Close an object
    @objc optional func dataSizeAs(_ as: NSNumber!) -> Int // Return the size in bytes of an object
    @objc optional func delete() -> SBObject // Move an item from its container to the trash
    @objc optional func duplicateTo(_ to: SBObject!, replacing: Bool, routingSuppressed: Bool, exactCopy: Bool) -> SBObject // Duplicate one or more object(s)
    @objc optional func exists() -> Bool // Verify if an object exists
    @objc optional func moveTo(_ to: SBObject!, replacing: Bool, positionedAt: [Any]!, routingSuppressed: Bool) -> SBObject // Move object(s) to a new location
    @objc optional func select() // Select the specified object(s)
    @objc optional func sortBy(_ by: Selector) -> SBObject // Return the specified object(s) in a sorted list
    @objc optional func cleanUpBy(_ by: Selector) // Arrange items in window nicely (only applies to open windows in icon view that are not kept arranged)
    @objc optional func eject() // Eject the specified disk(s)
    @objc optional func emptySecurity(_ security: Bool) // Empty the trash
    @objc optional func erase() // (NOT AVAILABLE) Erase the specified disk(s)
    @objc optional func reveal() // Bring the specified object(s) into view
    @objc optional func updateNecessity(_ necessity: Bool, registeringApplications: Bool) // Update the display of the specified object(s) to match their on-disk representation
}

// MARK: FinderApplication
@objc
public protocol FinderApplication: SBApplicationProtocol {
    @objc optional var clipboard: SBObject { get } // (NOT AVAILABLE YET) the Finder’s clipboard window (copy)
    @objc optional var name: String { get } // the Finder’s name (copy)
    @objc optional var visible: Bool { get } // Is the Finder’s layer visible?
    @objc optional var frontmost: Bool { get } // Is the Finder the frontmost process?
    @objc optional var selection: SBObject { get } // the selection in the frontmost Finder window (copy)
    @objc optional var insertionLocation: SBObject { get } // the container in which a new folder would appear if “New Folder” was selected (copy)
    @objc optional var productVersion: String { get } // the version of the System software running on this computer (copy)
    @objc optional var version: String { get } // the version of the Finder (copy)
    @objc optional var startupDisk: FinderDisk { get } // the startup disk (copy)
    @objc optional var desktop: FinderDesktopObject { get } // the desktop (copy)
    @objc optional var trash: FinderTrashObject { get } // the trash (copy)
    @objc optional var home: FinderFolder { get } // the home directory (copy)
    @objc optional var computerContainer: FinderComputerObject { get } // the computer location (as in Go > Computer) (copy)
    @objc optional var FinderPreferences: FinderPreferences { get } // Various preferences that apply to the Finder as a whole (copy)

    @objc optional var desktopPicture: FinderFile { get } // the desktop picture of the main monitor

    @objc optional func setDesktopPicture(_ desktopPicture: FinderFile!) // the desktop picture of the main monitor

    @objc optional func items() -> SBElementArray
    @objc optional func containers() -> SBElementArray
    @objc optional func disks() -> SBElementArray
    @objc optional func folders() -> SBElementArray
    @objc optional func files() -> SBElementArray
    @objc optional func aliasFiles() -> SBElementArray
    @objc optional func applicationFiles() -> SBElementArray
    @objc optional func documentFiles() -> SBElementArray
    @objc optional func internetLocationFiles() -> SBElementArray
    @objc optional func clippings() -> SBElementArray
    @objc optional func packages() -> SBElementArray
    @objc optional func windows() -> SBElementArray
    @objc optional func FinderWindows() -> SBElementArray
    @objc optional func clippingWindows() -> SBElementArray

    @objc optional func quit() // Quit the Finder
    @objc optional func activate() // Activate the specified window (or the Finder)
    @objc optional func copy() // (NOT AVAILABLE YET) Copy the selected items to the clipboard (the Finder must be the front application)
    @objc optional func eject() // Eject the specified disk(s)
    @objc optional func emptySecurity(_ security: Bool) // Empty the trash
    @objc optional func restart() // Restart the computer
    @objc optional func shutDown() // Shut Down the computer
    @objc optional func sleep() // Put the computer to sleep
    @objc optional func setVisible(_ visible: Bool) // Is the Finder’s layer visible?
    @objc optional func setFrontmost(_ frontmost: Bool) // Is the Finder the frontmost process?
    @objc optional func setSelection(_ selection: SBObject!) // the selection in the frontmost Finder window
}

extension SBApplication: FinderApplication {}

// MARK: FinderItem
@objc
public protocol FinderItem: SBObjectProtocol, FinderGenericMethods {
    @objc optional var name: String { get } // the name of the item (copy)
    @objc optional var displayedName: String { get } // the user-visible name of the item (copy)
    @objc optional var nameExtension: String { get } // the name extension of the item (such as “txt”) (copy)
    @objc optional var extensionHidden: Bool { get } // Is the item's extension hidden from the user?
    @objc optional var index: Int { get } // the index in the front-to-back ordering within its container
    @objc optional var container: SBObject { get } // the container of the item (copy)
    @objc optional var disk: SBObject { get } // the disk on which the item is stored (copy)
    @objc optional var position: NSPoint { get } // the position of the item within its parent window (can only be set for an item in a window viewed as icons or buttons)
    @objc optional var desktopPosition: NSPoint { get } // the position of the item on the desktop
    @objc optional var bounds: NSRect { get } // the bounding rectangle of the item (can only be set for an item in a window viewed as icons or buttons)
    @objc optional var labelIndex: Int { get } // the label of the item
    @objc optional var locked: Bool { get } // Is the file locked?
    @objc optional var kind: String { get } // the kind of the item (copy)
    @objc optional var objectDescription: String { get } // a description of the item (copy)
    @objc optional var comment: String { get } // the comment of the item, displayed in the “Get Info” window (copy)
    @objc optional var size: Int64 { get } // the logical size of the item
    @objc optional var physicalSize: Int64 { get } // the actual space used by the item on disk
    @objc optional var creationDate: Date { get } // the date on which the item was created (copy)
    @objc optional var modificationDate: Date { get } // the date on which the item was last modified (copy)
    @objc optional var icon: FinderIconFamily { get } // the icon bitmap of the item (copy)
    @objc optional var URL: String { get } // the URL of the item (copy)
    @objc optional var owner: String { get } // the user that owns the container (copy)
    @objc optional var group: String { get } // the user or group that has special access to the container (copy)
    @objc optional var ownerPrivileges: FinderPriv { get }
    @objc optional var groupPrivileges: FinderPriv { get }
    @objc optional var everyonesPrivileges: FinderPriv { get }
    @objc optional var informationWindow: SBObject { get } // the information window for the item (copy)
    @objc optional var properties: [AnyHashable: Any] { get } // every property of an item (copy)

    @objc optional func setName(_ name: String!) // the name of the item
    @objc optional func setNameExtension(_ nameExtension: String!) // the name extension of the item (such as “txt”)
    @objc optional func setExtensionHidden(_ extensionHidden: Bool) // Is the item's extension hidden from the user?
    @objc optional func setPosition(_ position: NSPoint) // the position of the item within its parent window (can only be set for an item in a window viewed as icons or buttons)
    @objc optional func setDesktopPosition(_ desktopPosition: NSPoint) // the position of the item on the desktop
    @objc optional func setBounds(_ bounds: NSRect) // the bounding rectangle of the item (can only be set for an item in a window viewed as icons or buttons)
    @objc optional func setLabelIndex(_ labelIndex: Int) // the label of the item
    @objc optional func setLocked(_ locked: Bool) // Is the file locked?
    @objc optional func setComment(_ comment: String!) // the comment of the item, displayed in the “Get Info” window
    @objc optional func setModificationDate(_ modificationDate: Date!) // the date on which the item was last modified
    @objc optional func setIcon(_ icon: FinderIconFamily!) // the icon bitmap of the item
    @objc optional func setOwner(_ owner: String!) // the user that owns the container
    @objc optional func setGroup(_ group: String!) // the user or group that has special access to the container
    @objc optional func setOwnerPrivileges(_ ownerPrivileges: FinderPriv)
    @objc optional func setGroupPrivileges(_ groupPrivileges: FinderPriv)
    @objc optional func setEveryonesPrivileges(_ everyonesPrivileges: FinderPriv)
    @objc optional func setProperties(_ properties: [AnyHashable: Any]!) // every property of an item
}

extension SBObject: FinderItem {}

// MARK: FinderContainer
@objc
public protocol FinderContainer: FinderItem {
    @objc optional var entireContents: SBObject { get } // the entire contents of the container, including the contents of its children (copy)
    @objc optional var expandable: Bool { get } // (NOT AVAILABLE YET) Is the container capable of being expanded as an outline?
    @objc optional var expanded: Bool { get } // (NOT AVAILABLE YET) Is the container opened as an outline? (can only be set for containers viewed as lists)
    @objc optional var completelyExpanded: Bool { get } // (NOT AVAILABLE YET) Are the container and all of its children opened as outlines? (can only be set for containers viewed as lists)
    @objc optional var containerWindow: SBObject { get } // the container window for this folder (copy)

    @objc optional func setExpanded(_ expanded: Bool) // (NOT AVAILABLE YET) Is the container opened as an outline? (can only be set for containers viewed as lists)
    @objc optional func setCompletelyExpanded(_ completelyExpanded: Bool) // (NOT AVAILABLE YET) Are the container and all of its children opened as outlines? (can only be set for containers viewed as lists)

    @objc optional func items() -> SBElementArray
    @objc optional func containers() -> SBElementArray
    @objc optional func folders() -> SBElementArray
    @objc optional func files() -> SBElementArray
    @objc optional func aliasFiles() -> SBElementArray
    @objc optional func applicationFiles() -> SBElementArray
    @objc optional func documentFiles() -> SBElementArray
    @objc optional func internetLocationFiles() -> SBElementArray
    @objc optional func clippings() -> SBElementArray
    @objc optional func packages() -> SBElementArray
}

extension SBObject: FinderContainer {}

// MARK: FinderComputerObject
@objc
public protocol FinderComputerObject: FinderItem {}

extension SBObject: FinderComputerObject {}

// MARK: FinderDisk
@objc
public protocol FinderDisk: FinderContainer {
    @objc optional var capacity: Int64 { get } // the total number of bytes (free or used) on the disk
    @objc optional var freeSpace: Int64 { get } // the number of free bytes left on the disk
    @objc optional var ejectable: Bool { get } // Can the media be ejected (floppies, CDs, and so on)?
    @objc optional var localVolume: Bool { get } // Is the media a local volume (as opposed to a file server)?
    @objc optional var startup: Bool { get } // Is this disk the boot disk?
    @objc optional var format: FinderEdfm { get } // the filesystem format of this disk
    @objc optional var journalingEnabled: Bool { get } // Does this disk do file system journaling?
    @objc optional var ignorePrivileges: Bool { get } // Ignore permissions on this disk?

    @objc optional func setIgnorePrivileges(_ ignorePrivileges: Bool) // Ignore permissions on this disk?

    @objc optional func id() -> Int // the unique id for this disk (unchanged while disk remains connected and Finder remains running)

    @objc optional func items() -> SBElementArray
    @objc optional func containers() -> SBElementArray
    @objc optional func folders() -> SBElementArray
    @objc optional func files() -> SBElementArray
    @objc optional func aliasFiles() -> SBElementArray
    @objc optional func applicationFiles() -> SBElementArray
    @objc optional func documentFiles() -> SBElementArray
    @objc optional func internetLocationFiles() -> SBElementArray
    @objc optional func clippings() -> SBElementArray
    @objc optional func packages() -> SBElementArray
}

extension SBObject: FinderDisk {}

// MARK: FinderFolder
@objc
public protocol FinderFolder: FinderContainer {
    @objc optional func items() -> SBElementArray
    @objc optional func containers() -> SBElementArray
    @objc optional func folders() -> SBElementArray
    @objc optional func files() -> SBElementArray
    @objc optional func aliasFiles() -> SBElementArray
    @objc optional func applicationFiles() -> SBElementArray
    @objc optional func documentFiles() -> SBElementArray
    @objc optional func internetLocationFiles() -> SBElementArray
    @objc optional func clippings() -> SBElementArray
    @objc optional func packages() -> SBElementArray
}

extension SBObject: FinderFolder {}

// MARK: FinderDesktopObject
@objc
public protocol FinderDesktopObject: FinderContainer {
    @objc optional func items() -> SBElementArray
    @objc optional func containers() -> SBElementArray
    @objc optional func disks() -> SBElementArray
    @objc optional func folders() -> SBElementArray
    @objc optional func files() -> SBElementArray
    @objc optional func aliasFiles() -> SBElementArray
    @objc optional func applicationFiles() -> SBElementArray
    @objc optional func documentFiles() -> SBElementArray
    @objc optional func internetLocationFiles() -> SBElementArray
    @objc optional func clippings() -> SBElementArray
    @objc optional func packages() -> SBElementArray
}

extension SBObject: FinderDesktopObject {}

// MARK: FinderTrashObject
@objc
public protocol FinderTrashObject: FinderContainer {
    @objc optional var warnsBeforeEmptying: Bool { get } // Display a dialog when emptying the trash?

    @objc optional func setWarnsBeforeEmptying(_ warnsBeforeEmptying: Bool) // Display a dialog when emptying the trash?

    @objc optional func items() -> SBElementArray
    @objc optional func containers() -> SBElementArray
    @objc optional func folders() -> SBElementArray
    @objc optional func files() -> SBElementArray
    @objc optional func aliasFiles() -> SBElementArray
    @objc optional func applicationFiles() -> SBElementArray
    @objc optional func documentFiles() -> SBElementArray
    @objc optional func internetLocationFiles() -> SBElementArray
    @objc optional func clippings() -> SBElementArray
    @objc optional func packages() -> SBElementArray
}

extension SBObject: FinderTrashObject {}

// MARK: FinderFile
@objc
public protocol FinderFile: FinderItem {
    @objc optional var fileType: NSNumber { get } // the OSType identifying the type of data contained in the item (copy)
    @objc optional var creatorType: NSNumber { get } // the OSType identifying the application that created the item (copy)
    @objc optional var stationery: Bool { get } // Is the file a stationery pad?
    @objc optional var productVersion: String { get } // the version of the product (visible at the top of the “Get Info” window) (copy)
    @objc optional var version: String { get } // the version of the file (visible at the bottom of the “Get Info” window) (copy)

    @objc optional func setFileType(_ fileType: NSNumber!) // the OSType identifying the type of data contained in the item
    @objc optional func setCreatorType(_ creatorType: NSNumber!) // the OSType identifying the application that created the item
    @objc optional func setStationery(_ stationery: Bool) // Is the file a stationery pad?
}

extension SBObject: FinderFile {}

// MARK: FinderAliasFile
@objc
public protocol FinderAliasFile: FinderFile {
    @objc optional var originalItem: SBObject { get } // the original item pointed to by the alias (copy)

    @objc optional func setOriginalItem(_ originalItem: SBObject!) // the original item pointed to by the alias
}

extension SBObject: FinderAliasFile {}

// MARK: FinderApplicationFile
@objc
public protocol FinderApplicationFile: FinderFile {
    @objc optional var suggestedSize: Int { get } // (AVAILABLE IN 10.1 TO 10.4) the memory size with which the developer recommends the application be launched
    @objc optional var minimumSize: Int { get } // (AVAILABLE IN 10.1 TO 10.4) the smallest memory size with which the application can be launched
    @objc optional var preferredSize: Int { get } // (AVAILABLE IN 10.1 TO 10.4) the memory size with which the application will be launched
    @objc optional var acceptsHighLevelEvents: Bool { get } // Is the application high-level event aware? (OBSOLETE: always returns true)
    @objc optional var hasScriptingTerminology: Bool { get } // Does the process have a scripting terminology, i.e., can it be scripted?
    @objc optional var opensInClassic: Bool { get } // (AVAILABLE IN 10.1 TO 10.4) Should the application launch in the Classic environment?

    @objc optional func setMinimumSize(_ minimumSize: Int) // (AVAILABLE IN 10.1 TO 10.4) the smallest memory size with which the application can be launched
    @objc optional func setPreferredSize(_ preferredSize: Int) // (AVAILABLE IN 10.1 TO 10.4) the memory size with which the application will be launched
    @objc optional func setOpensInClassic(_ opensInClassic: Bool) // (AVAILABLE IN 10.1 TO 10.4) Should the application launch in the Classic environment?

    @objc optional func id() -> String // the bundle identifier or creator type of the application
}

extension SBObject: FinderApplicationFile {}

// MARK: FinderDocumentFile
@objc
public protocol FinderDocumentFile: FinderFile {}

extension SBObject: FinderDocumentFile {}

// MARK: FinderInternetLocationFile
@objc
public protocol FinderInternetLocationFile: FinderFile {
    @objc optional var location: String { get } // the internet location (copy)
}

extension SBObject: FinderInternetLocationFile {}

// MARK: FinderClipping
@objc
public protocol FinderClipping: FinderFile {
    @objc optional var clippingWindow: SBObject { get } // (NOT AVAILABLE YET) the clipping window for this clipping (copy)
}

extension SBObject: FinderClipping {}

// MARK: FinderPackage
@objc
public protocol FinderPackage: FinderItem {}

extension SBObject: FinderPackage {}

// MARK: FinderWindow
@objc
public protocol FinderWindow: SBObjectProtocol, FinderGenericMethods {
    @objc optional var position: NSPoint { get } // the upper left position of the window
    @objc optional var bounds: NSRect { get } // the boundary rectangle for the window
    @objc optional var titled: Bool { get } // Does the window have a title bar?
    @objc optional var name: String { get } // the name of the window (copy)
    @objc optional var index: Int { get } // the number of the window in the front-to-back layer ordering
    @objc optional var closeable: Bool { get } // Does the window have a close box?
    @objc optional var floating: Bool { get } // Does the window have a title bar?
    @objc optional var modal: Bool { get } // Is the window modal?
    @objc optional var resizable: Bool { get } // Is the window resizable?
    @objc optional var zoomable: Bool { get } // Is the window zoomable?
    @objc optional var zoomed: Bool { get } // Is the window zoomed?
    @objc optional var visible: Bool { get } // Is the window visible (always true for open Finder windows)?
    @objc optional var collapsed: Bool { get } // Is the window collapsed
    @objc optional var properties: [AnyHashable: Any] { get } // every property of a window (copy)

    @objc optional func setPosition(_ position: NSPoint) // the upper left position of the window
    @objc optional func setBounds(_ bounds: NSRect) // the boundary rectangle for the window
    @objc optional func setIndex(_ index: Int) // the number of the window in the front-to-back layer ordering
    @objc optional func setZoomed(_ zoomed: Bool) // Is the window zoomed?
    @objc optional func setCollapsed(_ collapsed: Bool) // Is the window collapsed
    @objc optional func setProperties(_ properties: [AnyHashable: Any]!) // every property of a window

    @objc optional func id() -> Int // the unique id for this window
}

extension SBObject: FinderWindow {}

// MARK: FinderFinderWindow
@objc
public protocol FinderFinderWindow: FinderWindow {
    @objc optional var target: SBObject { get } // the container at which this file viewer is targeted (copy)
    @objc optional var currentView: FinderEcvw { get } // the current view for the container window
    @objc optional var iconViewOptions: FinderIconViewOptions { get } // the icon view options for the container window (copy)
    @objc optional var listViewOptions: FinderListViewOptions { get } // the list view options for the container window (copy)
    @objc optional var columnViewOptions: FinderColumnViewOptions { get } // the column view options for the container window (copy)
    @objc optional var toolbarVisible: Bool { get } // Is the window's toolbar visible?
    @objc optional var statusbarVisible: Bool { get } // Is the window's status bar visible?
    @objc optional var sidebarWidth: Int { get } // the width of the sidebar for the container window

    @objc optional func setTarget(_ target: SBObject!) // the container at which this file viewer is targeted
    @objc optional func setCurrentView(_ currentView: FinderEcvw) // the current view for the container window
    @objc optional func setToolbarVisible(_ toolbarVisible: Bool) // Is the window's toolbar visible?
    @objc optional func setStatusbarVisible(_ statusbarVisible: Bool) // Is the window's status bar visible?
    @objc optional func setSidebarWidth(_ sidebarWidth: Int) // the width of the sidebar for the container window
}

extension SBObject: FinderFinderWindow {}

// MARK: FinderDesktopWindow
@objc
public protocol FinderDesktopWindow: FinderFinderWindow {}

extension SBObject: FinderDesktopWindow {}

// MARK: FinderInformationWindow
@objc
public protocol FinderInformationWindow: FinderWindow {
    @objc optional var item: SBObject { get } // the item from which this window was opened (copy)
    @objc optional var currentPanel: FinderIpnl { get } // the current panel in the information window

    @objc optional func setCurrentPanel(_ currentPanel: FinderIpnl) // the current panel in the information window
}

extension SBObject: FinderInformationWindow {}

// MARK: FinderPreferencesWindow
@objc
public protocol FinderPreferencesWindow: FinderWindow {
    @objc optional var currentPanel: FinderPple { get } // The current panel in the Finder preferences window

    @objc optional func setCurrentPanel(_ currentPanel: FinderPple) // The current panel in the Finder preferences window
}

extension SBObject: FinderPreferencesWindow {}

// MARK: FinderClippingWindow
@objc
public protocol FinderClippingWindow: FinderWindow {}

extension SBObject: FinderClippingWindow {}

// MARK: FinderProcess
@objc
public protocol FinderProcess: SBObjectProtocol, FinderGenericMethods {
    @objc optional var name: String { get } // the name of the process (copy)
    @objc optional var visible: Bool { get } // Is the process' layer visible?
    @objc optional var frontmost: Bool { get } // Is the process the frontmost process?
    @objc optional var file: SBObject { get } // the file from which the process was launched (copy)
    @objc optional var fileType: NSNumber { get } // the OSType of the file type of the process (copy)
    @objc optional var creatorType: NSNumber { get } // the OSType of the creator of the process (the signature) (copy)
    @objc optional var acceptsHighLevelEvents: Bool { get } // Is the process high-level event aware (accepts open application, open document, print document, and quit)?
    @objc optional var acceptsRemoteEvents: Bool { get } // Does the process accept remote events?
    @objc optional var hasScriptingTerminology: Bool { get } // Does the process have a scripting terminology, i.e., can it be scripted?
    @objc optional var totalPartitionSize: Int { get } // the size of the partition with which the process was launched
    @objc optional var partitionSpaceUsed: Int { get } // the number of bytes currently used in the process' partition

    @objc optional func setVisible(_ visible: Bool) // Is the process' layer visible?
    @objc optional func setFrontmost(_ frontmost: Bool) // Is the process the frontmost process?
}

extension SBObject: FinderProcess {}

// MARK: FinderApplicationProcess
@objc
public protocol FinderApplicationProcess: FinderProcess {
    @objc optional var applicationFile: FinderApplicationFile { get } // the application file from which this process was launched (copy)
}

extension SBObject: FinderApplicationProcess {}

// MARK: FinderDeskAccessoryProcess
@objc
public protocol FinderDeskAccessoryProcess: FinderProcess {
    @objc optional var deskAccessoryFile: SBObject { get } // the desk accessory file from which this process was launched (copy)
}

extension SBObject: FinderDeskAccessoryProcess {}

// MARK: FinderPreferences
@objc
public protocol FinderPreferences: SBObjectProtocol, FinderGenericMethods {
    @objc optional var window: FinderPreferencesWindow { get } // the window that would open if Finder preferences was opened (copy)
    @objc optional var iconViewOptions: FinderIconViewOptions { get } // the default icon view options (copy)
    @objc optional var listViewOptions: FinderListViewOptions { get } // the default list view options (copy)
    @objc optional var columnViewOptions: FinderColumnViewOptions { get } // the column view options for all windows (copy)
    @objc optional var foldersSpringOpen: Bool { get } // Spring open folders after the specified delay?
    @objc optional var delayBeforeSpringing: Double { get } // the delay before springing open a container in seconds (from 0.167 to 1.169)
    @objc optional var desktopShowsHardDisks: Bool { get } // Hard disks appear on the desktop?
    @objc optional var desktopShowsExternalHardDisks: Bool { get } // External hard disks appear on the desktop?
    @objc optional var desktopShowsRemovableMedia: Bool { get } // CDs, DVDs, and iPods appear on the desktop?
    @objc optional var desktopShowsConnectedServers: Bool { get } // Connected servers appear on the desktop?
    @objc optional var newWindowTarget: SBObject { get } // target location for a newly-opened Finder window (copy)
    @objc optional var foldersOpenInNewWindows: Bool { get } // Folders open into new windows?
    @objc optional var foldersOpenInNewTabs: Bool { get } // Folders open into new tabs?
    @objc optional var newWindowsOpenInColumnView: Bool { get } // Open new windows in column view?
    @objc optional var allNameExtensionsShowing: Bool { get } // Show name extensions, even for items whose “extension hidden” is true?

    @objc optional func setFoldersSpringOpen(_ foldersSpringOpen: Bool) // Spring open folders after the specified delay?
    @objc optional func setDelayBeforeSpringing(_ delayBeforeSpringing: Double) // the delay before springing open a container in seconds (from 0.167 to 1.169)
    @objc optional func setDesktopShowsHardDisks(_ desktopShowsHardDisks: Bool) // Hard disks appear on the desktop?
    @objc optional func setDesktopShowsExternalHardDisks(_ desktopShowsExternalHardDisks: Bool) // External hard disks appear on the desktop?
    @objc optional func setDesktopShowsRemovableMedia(_ desktopShowsRemovableMedia: Bool) // CDs, DVDs, and iPods appear on the desktop?
    @objc optional func setDesktopShowsConnectedServers(_ desktopShowsConnectedServers: Bool) // Connected servers appear on the desktop?
    @objc optional func setNewWindowTarget(_ newWindowTarget: SBObject!) // target location for a newly-opened Finder window
    @objc optional func setFoldersOpenInNewWindows(_ foldersOpenInNewWindows: Bool) // Folders open into new windows?
    @objc optional func setFoldersOpenInNewTabs(_ foldersOpenInNewTabs: Bool) // Folders open into new tabs?
    @objc optional func setNewWindowsOpenInColumnView(_ newWindowsOpenInColumnView: Bool) // Open new windows in column view?
    @objc optional func setAllNameExtensionsShowing(_ allNameExtensionsShowing: Bool) // Show name extensions, even for items whose “extension hidden” is true?
}

extension SBObject: FinderPreferences {}

// MARK: FinderLabel
@objc
public protocol FinderLabel: SBObjectProtocol, FinderGenericMethods {
    @objc optional var name: String { get } // the name associated with the label (copy)
    @objc optional var index: Int { get } // the index in the front-to-back ordering within its container
    @objc optional var color: NSColor { get } // the color associated with the label (copy)

    @objc optional func setName(_ name: String!) // the name associated with the label
    @objc optional func setIndex(_ index: Int) // the index in the front-to-back ordering within its container
    @objc optional func setColor(_ color: NSColor!) // the color associated with the label
}

extension SBObject: FinderLabel {}

// MARK: FinderIconFamily
@objc
public protocol FinderIconFamily: SBObjectProtocol, FinderGenericMethods {
    @objc optional var largeMonochromeIconAndMask: Any { get } // the large black-and-white icon and the mask for large icons (copy)
    @objc optional var large8BitMask: Any { get } // the large 8-bit mask for large 32-bit icons (copy)
    @objc optional var large32BitIcon: Any { get } // the large 32-bit color icon (copy)
    @objc optional var large8BitIcon: Any { get } // the large 8-bit color icon (copy)
    @objc optional var large4BitIcon: Any { get } // the large 4-bit color icon (copy)
    @objc optional var smallMonochromeIconAndMask: Any { get } // the small black-and-white icon and the mask for small icons (copy)
    @objc optional var small8BitMask: Any { get } // the small 8-bit mask for small 32-bit icons (copy)
    @objc optional var small32BitIcon: Any { get } // the small 32-bit color icon (copy)
    @objc optional var small8BitIcon: Any { get } // the small 8-bit color icon (copy)
    @objc optional var small4BitIcon: Any { get } // the small 4-bit color icon (copy)
}

extension SBObject: FinderIconFamily {}

// MARK: FinderIconViewOptions
@objc
public protocol FinderIconViewOptions: SBObjectProtocol, FinderGenericMethods {
    @objc optional var arrangement: FinderEarr { get } // the property by which to keep icons arranged
    @objc optional var iconSize: Int { get } // the size of icons displayed in the icon view
    @objc optional var showsItemInfo: Bool { get } // additional info about an item displayed in icon view
    @objc optional var showsIconPreview: Bool { get } // displays a preview of the item in icon view
    @objc optional var textSize: Int { get } // the size of the text displayed in the icon view
    @objc optional var labelPosition: FinderEpos { get } // the location of the label in reference to the icon
    @objc optional var backgroundPicture: FinderFile { get } // the background picture of the icon view (copy)
    @objc optional var backgroundColor: NSColor { get } // the background color of the icon view (copy)

    @objc optional func setArrangement(_ arrangement: FinderEarr) // the property by which to keep icons arranged
    @objc optional func setIconSize(_ iconSize: Int) // the size of icons displayed in the icon view
    @objc optional func setShowsItemInfo(_ showsItemInfo: Bool) // additional info about an item displayed in icon view
    @objc optional func setShowsIconPreview(_ showsIconPreview: Bool) // displays a preview of the item in icon view
    @objc optional func setTextSize(_ textSize: Int) // the size of the text displayed in the icon view
    @objc optional func setLabelPosition(_ labelPosition: FinderEpos) // the location of the label in reference to the icon
    @objc optional func setBackgroundPicture(_ backgroundPicture: FinderFile!) // the background picture of the icon view
    @objc optional func setBackgroundColor(_ backgroundColor: NSColor!) // the background color of the icon view
}

extension SBObject: FinderIconViewOptions {}

// MARK: FinderColumnViewOptions
@objc
public protocol FinderColumnViewOptions: SBObjectProtocol, FinderGenericMethods {
    @objc optional var textSize: Int { get } // the size of the text displayed in the column view
    @objc optional var showsIcon: Bool { get } // displays an icon next to the label in column view
    @objc optional var showsIconPreview: Bool { get } // displays a preview of the item in column view
    @objc optional var showsPreviewColumn: Bool { get } // displays the preview column in column view
    @objc optional var disclosesPreviewPane: Bool { get } // discloses the preview pane of the preview column in column view

    @objc optional func setTextSize(_ textSize: Int) // the size of the text displayed in the column view
    @objc optional func setShowsIcon(_ showsIcon: Bool) // displays an icon next to the label in column view
    @objc optional func setShowsIconPreview(_ showsIconPreview: Bool) // displays a preview of the item in column view
    @objc optional func setShowsPreviewColumn(_ showsPreviewColumn: Bool) // displays the preview column in column view
    @objc optional func setDisclosesPreviewPane(_ disclosesPreviewPane: Bool) // discloses the preview pane of the preview column in column view
}

extension SBObject: FinderColumnViewOptions {}

// MARK: FinderListViewOptions
@objc
public protocol FinderListViewOptions: SBObjectProtocol, FinderGenericMethods {
    @objc optional var calculatesFolderSizes: Bool { get } // Are folder sizes calculated and displayed in the window?
    @objc optional var showsIconPreview: Bool { get } // displays a preview of the item in list view
    @objc optional var iconSize: FinderLvic { get } // the size of icons displayed in the list view
    @objc optional var textSize: Int { get } // the size of the text displayed in the list view
    @objc optional var sortColumn: FinderColumn { get } // the column that the list view is sorted on (copy)
    @objc optional var usesRelativeDates: Bool { get } // Are relative dates (e.g., today, yesterday) shown in the list view?

    @objc optional func setCalculatesFolderSizes(_ calculatesFolderSizes: Bool) // Are folder sizes calculated and displayed in the window?
    @objc optional func setShowsIconPreview(_ showsIconPreview: Bool) // displays a preview of the item in list view
    @objc optional func setIconSize(_ iconSize: FinderLvic) // the size of icons displayed in the list view
    @objc optional func setTextSize(_ textSize: Int) // the size of the text displayed in the list view
    @objc optional func setSortColumn(_ sortColumn: FinderColumn!) // the column that the list view is sorted on
    @objc optional func setUsesRelativeDates(_ usesRelativeDates: Bool) // Are relative dates (e.g., today, yesterday) shown in the list view?

    @objc optional func columns() -> SBElementArray
}

extension SBObject: FinderListViewOptions {}

// MARK: FinderColumn
@objc
public protocol FinderColumn: SBObjectProtocol, FinderGenericMethods {
    @objc optional var index: Int { get } // the index in the front-to-back ordering within its container
    @objc optional var name: FinderElsv { get } // the column name
    @objc optional var sortDirection: FinderSodr { get } // The direction in which the window is sorted
    @objc optional var width: Int { get } // the width of this column
    @objc optional var minimumWidth: Int { get } // the minimum allowed width of this column
    @objc optional var maximumWidth: Int { get } // the maximum allowed width of this column
    @objc optional var visible: Bool { get } // is this column visible

    @objc optional func setIndex(_ index: Int) // the index in the front-to-back ordering within its container
    @objc optional func setSortDirection(_ sortDirection: FinderSodr) // The direction in which the window is sorted
    @objc optional func setWidth(_ width: Int) // the width of this column
    @objc optional func setVisible(_ visible: Bool) // is this column visible
}

extension SBObject: FinderColumn {}

// MARK: FinderAliasList
@objc
public protocol FinderAliasList: SBObjectProtocol, FinderGenericMethods {}

extension SBObject: FinderAliasList {}
