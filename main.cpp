#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QDir>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Daimler AG RD/DDA");
    app.setApplicationName("timecop");

    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat,
                       QSettings::UserScope,
                       QDir::currentPath());

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
