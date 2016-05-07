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
public:
    explicit SystrayHelper(QObject *parent = 0);
    void setRootWindow(QObject *rootObject);

signals:

public slots:
    void activatedSystray(const QSystemTrayIcon::ActivationReason &reason) {
         qDebug() << "reason " << reason;
        switch (reason) {
        case QSystemTrayIcon::DoubleClick:
            qDebug() << "context";
            break;
        default:
            qDebug() << "default";
            if(m_rootObject != 0){
                qDebug()<< m_rootObject->isWindowType();

            }
            break;
        }
    }
};

#endif // SYSTRAYHELPER_H
