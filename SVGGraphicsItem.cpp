#include <QGraphicsItem>
#include <QSvgRenderer>
#include <QPainter>

class SvgGraphicsItem : public QGraphicsItem {
public:
    SvgGraphicsItem(const QString &filePath) {
        renderer.load(filePath);
    }

    QRectF boundingRect() const override {
        return QRectF(0, 0, renderer.defaultSize().width(), renderer.defaultSize().height());
    }

    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget = nullptr) override {
        renderer.render(painter, boundingRect());
    }

private:
    QSvgRenderer renderer;
};
