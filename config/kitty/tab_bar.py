from kitty.tab_bar import (
    DrawData, ExtraData, Screen, TabBarData, as_rgb,
    color_as_int, draw_title
)
from kitty.utils import color_as_int

# 分隔符：tab 之间的间隔
SEPARATOR = " "


def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int, is_last: bool,
    extra_data: ExtraData
) -> int:
    """
    自定义 tab bar 绘制：
    - 每个 tab 有独立背景色块
    - tab 之间用空格分隔
    - 最后填充背景色到行尾，实现 100% 宽度背景条
    """
    # 保存当前 tab 的颜色
    tab_bg = screen.cursor.bg
    tab_fg = screen.cursor.fg
    default_bg = as_rgb(int(draw_data.default_bg))

    # 绘制 tab 标题前的空格（作为 tab 的左内边距）
    screen.cursor.bg = tab_bg
    screen.draw(" ")

    # 绘制 tab 标题
    draw_title(draw_data, screen, tab, index, max_tab_length)

    # 绘制 tab 标题后的空格（作为 tab 的右内边距）
    screen.draw(" ")

    end = screen.cursor.x

    # 如果不是最后一个 tab，绘制分隔空格（使用默认背景色）
    if not is_last:
        screen.cursor.bg = default_bg
        screen.cursor.fg = default_bg
        screen.draw(SEPARATOR)
    else:
        # 最后一个 tab：填充剩余空间到行尾，形成 100% 宽度背景条
        # 使用 tab_bar_background（即 default_bg）填充
        screen.cursor.bg = default_bg
        screen.cursor.fg = default_bg
        remaining = screen.columns - screen.cursor.x
        if remaining > 0:
            screen.draw(" " * remaining)

    # 重置背景
    screen.cursor.bg = 0
    return end
