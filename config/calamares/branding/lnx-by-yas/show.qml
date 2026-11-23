import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            Column {
                anchors.centerIn: parent
                spacing: 12
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Selamat Datang di LNX by YAS"
                    color: "#ffffff"
                    font.pixelSize: 26
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Ringan ala Puppy RAM Mode, familiar seperti Windows 11."
                    color: "#bac2de"
                    font.pixelSize: 15
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            Column {
                anchors.centerIn: parent
                spacing: 12
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Dukungan Penuh APT, Snap & Flatpak"
                    color: "#ffffff"
                    font.pixelSize: 26
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Ribuan aplikasi siap dipasang langsung dari Flathub dan Snap Store."
                    color: "#bac2de"
                    font.pixelSize: 15
                }
            }
        }
    }
}