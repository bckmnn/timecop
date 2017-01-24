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
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    const QString app_name("timecop");
    const QString app_version("1.1");
    const QString app_settings_dir(QDir::home().filePath(".timecop"));

    app.setOrganizationName("Daimler AG RD-DDA");
    app.setApplicationName(app_name);

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat,
                       QSettings::UserScope,
                       app_settings_dir);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject *root = 0;
    QWidget *rootWindow = 0;
    SystrayHelper systrayHelper;
    engine.rootContext()->setContextProperty("systrayHelper", &systrayHelper);

    engine.rootContext()->setContextProperty("app_name",  app_name);
    engine.rootContext()->setContextProperty("app_version",  app_version);
    engine.rootContext()->setContextProperty("app_settings_dir",  app_settings_dir);


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
            QIcon icon(":/trayicon.png");
            icon.setIsMask(true);
            //trayIcon->setContextMenu(trayIconMenu);
            trayIcon->setIcon(icon);
            trayIcon->setToolTip("Click to open");
            trayIcon->setVisible(true);
            systrayHelper.setTrayIcon(trayIcon);
            QObject::connect(trayIcon, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), &systrayHelper, SLOT(activatedSystray(QSystemTrayIcon::ActivationReason)));

            trayIcon->show();
        }

    }

    return app.exec();
}
