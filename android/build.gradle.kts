plugins {
    // Make sure to include your Android and Kotlin plugins here if needed, e.g.:
    // id("com.android.application") version "8.5.2" apply false
    // id("org.jetbrains.kotlin.android") version "1.9.23" apply false

    // ✅ Google Services plugin for Firebase
    id("com.google.gms.google-services") version "4.4.3" apply false
}

buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2' // latest version
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
