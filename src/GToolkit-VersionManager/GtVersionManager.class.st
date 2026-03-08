Class {
	#name : 'GtVersionManager',
	#superclass : 'Object',
	#instVars : [
		'githubReleases',
		'feenkSite',
		'installDirectory'
	],
	#classInstVars : [
		'default'
	],
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'instance creation' }
GtVersionManager class >> default [
	^ default ifNil: [ default := self new ]
]

{ #category : 'instance creation' }
GtVersionManager class >> reset [
	default := nil
]

{ #category : 'private' }
GtVersionManager >> comparisonData [
	"Build a comparison table across all data sources"
	| githubVersions feenkVersions installedVersions allVersions currentVersionStr |
	githubVersions := Dictionary new.
	self githubReleases do: [ :r | 
		githubVersions at: r tagName put: r ].
	feenkVersions := self feenkSite versions asSet.
	installedVersions := (self installations collect: #version) asSet.
	currentVersionStr := self currentVersion versionString.
	allVersions := (githubVersions keys asSet, feenkVersions, installedVersions) 
		asOrderedCollection
		sorted: [ :a :b | 
			(GtRlSemanticVersionNumber createFromString: a) >= 
			(GtRlSemanticVersionNumber createFromString: b) ].
	^ allVersions collect: [ :v |
		| ghRelease published |
		ghRelease := githubVersions at: v ifAbsent: [ nil ].
		published := ghRelease 
			ifNotNil: [ ghRelease publishedAt asLocalStringYMDHM ] 
			ifNil: [ '' ].
		{ 
			#version -> v.
			#onGithub -> (githubVersions includesKey: v).
			#onFeenk -> (feenkVersions includes: v).
			#installed -> (installedVersions includes: v).
			#isCurrent -> (v = currentVersionStr).
			#published -> published.
		} asDictionary ]
]

{ #category : 'accessing' }
GtVersionManager >> currentPlatformLabel [
	"Human-readable label for the current platform"
	| os arch |
	os := Smalltalk os isWindows
		ifTrue: [ 'Windows' ]
		ifFalse: [ Smalltalk os isMacOS
			ifTrue: [ 'macOS' ]
			ifFalse: [ 'Linux' ] ].
	arch := (LibC resultOfCommand: 'uname -m') trimBoth.
	^ os, ' (', arch, ')'
]

{ #category : 'accessing' }
GtVersionManager >> currentVersion [
	^ GtImage instance version
]

{ #category : 'actions' }
GtVersionManager >> downloadRelease: aGtVmRelease [
	"Download the current-platform asset for a release to the install directory"
	| asset targetDir zipFile |
	asset := aGtVmRelease assetForCurrentPlatform.
	asset ifNil: [ self error: 'No asset available for current platform' ].
	targetDir := self installDirectory / aGtVmRelease tagName.
	targetDir ensureCreateDirectory.
	zipFile := targetDir / asset name.
	zipFile exists ifTrue: [ ^ zipFile ].
	ZnClient new
		url: asset downloadUrl;
		downloadTo: zipFile.
	^ zipFile
]

{ #category : 'actions' }
GtVersionManager >> extractZip: aZipFileReference inDirectory: aDirectoryReference [
	"Extract a zip file into a directory"
	| archive |
	archive := ZipArchive new readFrom: aZipFileReference.
	archive extractAllTo: aDirectoryReference.
	^ aDirectoryReference
]

{ #category : 'accessing' }
GtVersionManager >> feenkSite [
	^ feenkSite ifNil: [ feenkSite := GtVmFeenkSite new ]
]

{ #category : 'private' }
GtVersionManager >> githubClient [
	"Create a ZnClient configured for GitHub API access"
	| client |
	client := ZnClient new
		accept: 'application/vnd.github.v3+json'.
	GtGitHubTokenHolder token ifNotNil: [ :token |
		client setBearerAuthentication: token ].
	^ client
]

{ #category : 'accessing - github' }
GtVersionManager >> githubLatestRelease [
	"Fetch only the latest release"
	| response parsed |
	response := self githubClient
		url: 'https://api.github.com/repos/feenkcom/gtoolkit/releases/latest';
		get.
	parsed := [ STONJSON fromString: response ] on: Error do: [ :e | Dictionary new ].
	^ GtVmRelease new rawData: parsed
]

{ #category : 'accessing - github' }
GtVersionManager >> githubReleaseForTag: aTagString [
	"Fetch a specific release by tag name, e.g. 'v1.1.247'"
	| response parsed |
	response := self githubClient
		url: 'https://api.github.com/repos/feenkcom/gtoolkit/releases/tags/', aTagString;
		get.
	parsed := [ STONJSON fromString: response ] on: Error do: [ :e | Dictionary new ].
	^ GtVmRelease new rawData: parsed
]

{ #category : 'accessing - github' }
GtVersionManager >> githubReleases [
	"Fetch recent releases from GitHub (first page, 30 releases)"
	^ githubReleases ifNil: [
		githubReleases := self githubReleasesPerPage: 30 page: 1 ]
]

{ #category : 'accessing - github' }
GtVersionManager >> githubReleasesPerPage: count page: pageNumber [
	"Fetch releases from GitHub API with pagination"
	| response parsed |
	response := self githubClient
		url: 'https://api.github.com/repos/feenkcom/gtoolkit/releases';
		queryAt: 'per_page' put: count asString;
		queryAt: 'page' put: pageNumber asString;
		get.
	parsed := [ STONJSON fromString: response ] on: Error do: [ :e | #() ].
	^ GtVmReleaseGroup new rawData: parsed
]

{ #category : 'views' }
GtVersionManager >> gtActionRefreshFor: anAction [
	<gtAction>
	^ anAction button
		tooltip: 'Refresh all data sources';
		priority: 1;
		icon: BrGlamorousVectorIcons refresh;
		action: [ :aButton |
			self refresh.
			aButton phlow fireToolUpdateWish ]
]

{ #category : 'views' }
GtVersionManager >> gtComparisonFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Version comparison';
		priority: 5;
		items: [ self comparisonData ];
		column: 'Version' text: [ :row | 
			| text |
			text := (row at: #version) asRopedText.
			(row at: #isCurrent) ifTrue: [ text bold ].
			text ] width: 120;
		column: 'GitHub' text: [ :row | 
			(row at: #onGithub) 
				ifTrue: [ 'yes' asRopedText foreground: Color darkGray ]
				ifFalse: [ 'no' ] ] width: 70;
		column: 'dl.feenk.com' text: [ :row |
			(row at: #onFeenk) 
				ifTrue: [ 'yes' asRopedText foreground: Color darkGray ]
				ifFalse: [ 'no' ] ] width: 90;
		column: 'Installed' text: [ :row |
			(row at: #installed) 
				ifTrue: [ 'yes' asRopedText foreground: (Color r: 0.0 g: 0.6 b: 0.0); bold ]
				ifFalse: [ 'no' ] ] width: 70;
		column: 'Published' text: [ :row | row at: #published ] width: 150;
		send: [ :row |
			(row at: #onGithub) 
				ifTrue: [ self githubReleaseForTag: (row at: #version) ]
				ifFalse: [ row ] ]
]

{ #category : 'views' }
GtVersionManager >> gtFeenkSiteFor: aView [
	<gtView>
	^ aView columnedList
		title: 'dl.feenk.com';
		priority: 15;
		items: [ self feenkSite versions collect: [ :v | v -> (self feenkSite buildsForVersion: v) ] ];
		column: 'Version' text: [ :assoc | 
			| text |
			text := assoc key asRopedText.
			(assoc key = self currentVersion versionString)
				ifTrue: [ text bold ].
			text ] width: 120;
		column: 'Platforms' text: [ :assoc | assoc value size ] width: 80;
		column: 'Date' text: [ :assoc | assoc value first dateString ] width: 150;
		send: [ :assoc | assoc value ]
]

{ #category : 'views' }
GtVersionManager >> gtGithubReleasesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'GitHub releases';
		priority: 10;
		items: [ self githubReleases items ];
		column: 'Version' text: [ :r | 
			r isCurrentVersion 
				ifTrue: [ r tagName asRopedText bold ]
				ifFalse: [ r tagName ] ] width: 120;
		column: 'Published' text: [ :r | r publishedAt asLocalStringYMDHM ] width: 150;
		column: 'Author' text: #authorLogin width: 120;
		column: 'Downloads' text: #totalDownloads width: 80;
		column: 'Platforms' text: [ :r | r assets platformBuilds size ] width: 70
]

{ #category : 'views' }
GtVersionManager >> gtInstallationsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Installations';
		priority: 20;
		items: [ self installations ];
		column: 'Version' text: #version width: 120;
		column: 'Path' text: [ :i | i path fullName ]
]

{ #category : 'views' }
GtVersionManager >> gtOverviewFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ {
			'Current version' -> self currentVersion versionString.
			'Current platform' -> self currentPlatformLabel.
			'Install directory' -> self installDirectory fullName.
			'Local installations' -> self installations size.
			'dl.feenk.com versions' -> (', ' join: self feenkSite versions).
			'dl.feenk.com latest' -> self feenkSite latestVersion.
		} ];
		column: 'Property' text: #key;
		column: 'Value' text: #value
]

{ #category : 'accessing - local' }
GtVersionManager >> hasInstallation: aVersionString [
	^ self installations anySatisfy: [ :i | i version = aVersionString ]
]

{ #category : 'accessing' }
GtVersionManager >> installDirectory [
	^ installDirectory ifNil: [ 
		installDirectory := FileLocator home / '.gt-versions' ]
]

{ #category : 'accessing' }
GtVersionManager >> installDirectory: aFileReference [
	installDirectory := aFileReference
]

{ #category : 'actions' }
GtVersionManager >> installRelease: aGtVmRelease [
	"Download and extract a release for the current platform"
	| zipFile targetDir |
	targetDir := self installDirectory / aGtVmRelease tagName.
	zipFile := self downloadRelease: aGtVmRelease.
	self extractZip: zipFile inDirectory: targetDir.
	zipFile delete.
	^ GtVmInstallation new
		path: targetDir;
		version: aGtVmRelease tagName
]

{ #category : 'accessing - local' }
GtVersionManager >> installations [
	"List locally installed GT versions"
	| dir |
	dir := self installDirectory.
	dir exists ifFalse: [ ^ #() ].
	^ (dir directories sorted: [ :a :b | a basename > b basename ])
		collect: [ :each |
			GtVmInstallation new
				path: each;
				version: each basename ]
]

{ #category : 'printing' }
GtVersionManager >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' (current: ';
		print: self currentVersion;
		nextPut: $)
]

{ #category : 'actions' }
GtVersionManager >> refresh [
	githubReleases := nil.
	feenkSite ifNotNil: [ feenkSite refresh ]
]
