Class {
	#name : 'GtVersionManagerExamples',
	#superclass : 'Object',
	#category : 'GToolkit-VersionManager',
	#package : 'GToolkit-VersionManager'
}

{ #category : 'examples' }
GtVersionManagerExamples >> feenkSite [
	<gtExample>
	<noTest>
	| site |
	site := GtVmFeenkSite new.
	self assert: site entries isNotEmpty.
	self assert: site versions isNotEmpty.
	^ site
]

{ #category : 'examples' }
GtVersionManagerExamples >> githubLatestRelease [
	<gtExample>
	<noTest>
	| release |
	release := GtVersionManager default githubLatestRelease.
	self assert: release tagName isNotNil.
	self assert: release assets size > 0.
	^ release
]

{ #category : 'examples' }
GtVersionManagerExamples >> githubReleases [
	<gtExample>
	<noTest>
	| releases |
	releases := GtVersionManager default githubReleases.
	self assert: releases size > 0.
	self assert: releases latest tagName isNotNil.
	^ releases
]

{ #category : 'examples' }
GtVersionManagerExamples >> releaseAssets [
	<gtExample>
	<noTest>
	| release assets platformBuilds |
	release := GtVersionManager default githubLatestRelease.
	assets := release assets.
	platformBuilds := assets platformBuilds.
	self assert: platformBuilds size >= 6.
	self assert: (platformBuilds anySatisfy: [ :a | a platform = 'MacOS' ]).
	self assert: (platformBuilds anySatisfy: [ :a | a platform = 'Linux' ]).
	self assert: (platformBuilds anySatisfy: [ :a | a platform = 'Windows' ]).
	^ assets
]

{ #category : 'examples' }
GtVersionManagerExamples >> versionManager [
	<gtExample>
	<noTest>
	^ GtVersionManager default
]
