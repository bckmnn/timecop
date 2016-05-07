#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QDir>
#include <QAction>
#include <QMenu>
#include <QSystemTrayIcon>
#include <QDebug>
#include <QWindow>
#include <systrayhelper.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    app.setOrganizationName("Daimler AG RD/DDA");
    app.setApplicationName("timecop");

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat,
                       QSettings::UserScope,
                       QDir::currentPath());

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject *root = 0;
    QWidget *rootWindow = 0;
    SystrayHelper systrayHelper;
    if (engine.rootObjects().size() > 0)
    {
        root = engine.rootObjects().at(0);
        systrayHelper.setRootWindow(root);
        if(root->isWindowType()){
            rootWindow = qobject_cast<QWidget*>(root);

            QApplication::setQuitOnLastWindowClosed(false);

            QAction *minimizeAction = new QAction(QObject::tr("Mi&nimize"), rootWindow);
            rootWindow->connect(minimizeAction, SIGNAL(triggered()), root, SLOT(hide()));
            QAction *maximizeAction = new QAction(QObject::tr("Ma&ximize"), rootWindow);
            rootWindow->connect(maximizeAction, SIGNAL(triggered()), root, SLOT(showMaximized()));
            QAction *restoreAction = new QAction(QObject::tr("&Restore"), rootWindow);
            rootWindow->connect(restoreAction, SIGNAL(triggered()), root, SLOT(showNormal()));
            QAction *quitAction = new QAction(QObject::tr("&Quit"), rootWindow);
            rootWindow->connect(quitAction, SIGNAL(triggered()), qApp, SLOT(quit()));

            QMenu *trayIconMenu = new QMenu(rootWindow);
            trayIconMenu->addAction(minimizeAction);
            trayIconMenu->addAction(maximizeAction);
            trayIconMenu->addAction(restoreAction);
            trayIconMenu->addSeparator();
            trayIconMenu->addAction(quitAction);

            QSystemTrayIcon *trayIcon = new QSystemTrayIcon(rootWindow);
            //trayIcon->setContextMenu(trayIconMenu);
            trayIcon->setIcon(QIcon(":/icon.png"));
            trayIcon->setToolTip("Click to open");
            trayIcon->setVisible(true);
            QObject::connect(trayIcon, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), &systrayHelper, SLOT(activatedSystray(QSystemTrayIcon::ActivationReason)));

            trayIcon->show();
        }

    }

    return app.exec();
}
