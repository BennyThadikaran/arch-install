from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Screen, Key, Group, Match
from libqtile.lazy import lazy
import os
import subprocess

mod = "mod4"
terminal = "alacritty"
browser = "firefox"


# Keybindings
keys = [
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key(
        [mod, "shift"],
        "Return",
        lazy.spawn("rofi -show drun -show-icons"),
        desc="Run Launcher",
    ),
    Key(["mod4", "shift"], "l", lazy.spawn("i3lock -c 000000"), desc="Lock screen"),
    # Increase brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%")),
    # Decrease brightness
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
    Key([mod], "f", lazy.spawn(browser), desc="Web browser"),
    Key([mod], "b", lazy.hide_show_bar(), desc="Toggle bar"),
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle layout"),
    Key([mod], "q", lazy.window.kill(), desc="Close Window"),
    Key([mod], "e", lazy.spawn("pcmanfm"), desc="File Manager"),
    Key([mod, "shift"], "w", lazy.spawn("nitrogen"), desc="Set Wallpaper"),
    # Switch between windows
    # Some layouts like 'monadtall' only need to use j/k to move
    # through the stack, but other layouts like 'columns' will
    # require all four directions h/j/k/l to move around.
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab",
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab",
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab",
    ),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab",
    ),
]

# Groups (Workspaces)
groups = [Group(i) for i in "123456789"]
for i in groups:
    keys.extend(
        [
            Key([mod], i.name, lazy.group[i.name].toscreen()),
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
        ]
    )

# Layouts
layouts = [
    layout.MonadTall(border_focus="#1ABC9C", border_width=2, margin=8),
    layout.Max(),
]

# Fonts
widget_defaults = dict(
    font="MesloLGS Nerd Font",
    fontsize=14,
    padding=4,
)
extension_defaults = widget_defaults.copy()


# Bar and Widgets
def init_widgets_list():
    return [
        widget.CurrentLayoutIcon(scale=0.7),
        widget.GroupBox(
            highlight_method="line",
            active="#f8f8f2",
            inactive="#6272a4",
            highlight_color=["#44475a", "#282a36"],
            this_current_screen_border="#ff79c6",
            rounded=True,
        ),
        widget.Spacer(),
        widget.Image(filename="~/.config/qtile/icons/microchip.png"),
        widget.CPU(
            format="{load_percent:>3.0f}%",
            width=50,
            padding=0,
            foreground="#2ECC71",
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal + " -e htop")},
        ),
        widget.Image(filename="~/.config/qtile/icons/memory.png"),
        widget.Memory(
            format="{MemPercent:>3.0f}%",
            width=50,
            padding=0,
            foreground="#E74C3C",
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal + " -e htop")},
        ),
        widget.Image(filename="~/.config/qtile/icons/hard-drive.png"),
        widget.Memory(
            format="{SwapPercent:>3.0f}%",
            width=50,
            padding=0,
            foreground="#F1C40F",
        ),
        widget.Image(filename="~/.config/qtile/icons/wifi.png"),
        widget.Net(
            format="{down:>5} ↓ {up:>5} ↑",
            width=140,
            padding=0,
            foreground="#ECF0F1",
        ),
        # 🔈 Volume Widget
        widget.Image(filename="~/.config/qtile/icons/volume.png"),
        widget.Volume(
            fmt="{} ",
            foreground="#ECF0F1",
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn("pavucontrol")},
            volume_down_command="amixer -D pulse sset Master 5%-",
            volume_up_command="amixer -D pulse sset Master 5%+",
        ),
        widget.CheckUpdates(
            distro="Arch",
            display_format="🛡️ {updates}",
            no_update_string="No Updates",
            colour_have_updates="#E74C3C",
            colour_no_updates="#2ECC71",
            update_interval=14400,
            mouse_callbacks={
                "Button1": lambda: qtile.cmd_spawn(terminal + " -e sudo pacman -Syu")
            },
        ),
        # 📦 WidgetBox for Bluetooth and Backlight
        widget.WidgetBox(
            widgets=[
                widget.Bluetooth(
                    foreground="#1ABC9C",
                    mouse_callbacks={
                        "Button1": lambda: qtile.cmd_spawn("blueman-manager")
                    },
                ),
                widget.Backlight(
                    backlight_name="intel_backlight",  # Adjust based on your hardware
                    format="☀ {percent:2.0%}",
                    foreground="#F1C40F",
                ),
            ],
            text_closed="",  # Icon when collapsed
            text_open="",  # Icon when expanded
            foreground="#BDC3C7",
        ),
        widget.Clock(
            format=" %a, %b %d, %Y - %H:%M:%S ",
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn("yad --calendar")},
            foreground="#1ABC9C",
        ),
        widget.Systray(),
    ]


screens = [
    Screen(
        top=bar.Bar(
            widgets=init_widgets_list(), size=24, background="#282a36", opacity=0.95
        )
    ),
]

mouse = []


@hook.subscribe.startup_once
def autostart():
    autostart_script = os.path.expanduser("~/.config/qtile/autostart.sh")
    if os.path.isfile(autostart_script):
        subprocess.run([autostart_script])


floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="yad"),  # for calendar popup
    ]
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
wmname = "Qtile"
