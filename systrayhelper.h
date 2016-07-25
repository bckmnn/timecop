#ifndef SYSTRAYHELPER_H
#define SYSTRAYHELPER_H

#include <QObject>
#include <QSystemTrayIcon>
#include <QDebug>
#include <QWidget>

class SystrayHelper : public QObject
{
    Q_OBJECT
    QObject *m_rootObject;
    QSystemTrayIcon *m_trayicon;
public:
    explicit SystrayHelper(QObject *parent = 0);
    void setRootWindow(QObject *rootObject);
    void setTrayIcon(QSystemTrayIcon *trayicon);
signals:

public slots:
    void setToolTip(QString text);
    void activatedSystray(const QSystemTrayIcon::ActivationReason &reason) {
        switch (reason) {
        case QSystemTrayIcon::DoubleClick:
            if(m_rootObject != 0){
                QMetaObject::invokeMethod(m_rootObject, "systrayActivated", Q_ARG(QVariant, reason));
            }
            break;
        default:
            if(m_rootObject != 0){
                QMetaObject::invokeMethod(m_rootObject, "systrayActivated", Q_ARG(QVariant, reason));
            }
            break;
        }
    }
};

#endif // SYSTRAYHELPER_H
