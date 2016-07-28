#include "systrayhelper.h"
#include <QPixmap>
#include <QPainter>

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

void SystrayHelper::setIconColor(double percentRegular, double percentExtra)
{
    QPixmap iconPixmap(":/trayicon.png");
    QPainter *paint = new QPainter(&iconPixmap);
    paint->setBrush(*(new QColor(60,60,60,255)));
    paint->drawRect(0,450,591,100);

    if(percentExtra > 0){
        paint->setBrush(*(new QColor(255,255,127,255)));
        paint->drawRect(0,450,591*percentExtra,100);
    }else{
        paint->setBrush(*(new QColor(0,200,127,255)));
        paint->drawRect(0,450,591*percentRegular,100);
    }

    delete paint;
    QIcon icon(iconPixmap);
    //icon.setIsMask(true);
    m_trayicon->setIcon(icon);
}

void SystrayHelper::setTrayIcon(QSystemTrayIcon *trayicon)
{
    m_trayicon = trayicon;
}

SystrayHelper::SystrayHelper(QObject *parent) : QObject(parent)
{
}
