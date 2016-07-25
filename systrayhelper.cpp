#include "systrayhelper.h"

void SystrayHelper::setRootWindow(QObject *rootObject)
{
    m_rootObject = rootObject;
}

void SystrayHelper::setToolTip(QString text)
{
    if(m_trayicon){
        m_trayicon->setToolTip(text);
    }
}

void SystrayHelper::setTrayIcon(QSystemTrayIcon *trayicon)
{
    m_trayicon = trayicon;
}

SystrayHelper::SystrayHelper(QObject *parent) : QObject(parent)
{
}
