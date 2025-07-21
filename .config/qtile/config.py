from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Screen, Key, Group, Match
from libqtile.lazy import lazy
import os
import subprocess

mod = "mod4"
terminal = "alacritty"
browser = "firefox-esr"


# Keybindings
keys = [
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key(
        [mod, "shift"],
        "Return",
        lazy.spawn("rofi -show drun -show-icons"),
        desc="Run Launcher",
    ),
    Key([mod, "shift"], "q", lazy.shutdown()),
    Key([mod, "shift"], "p", lazy.spawn("/home/benny/scripts/powermenu.sh")),
    Key(["mod1"], "Tab", lazy.spawn("rofi -show window")),
    Key([], "Print", lazy.spawn("/home/benny/scripts/screenshot.sh")),
    Key(
        ["control", "mod1"],
        "KP_Delete",
        lazy.spawn("i3lock -i /home/benny/Pictures/ayu-dark.png"),
        desc="Lock screen",
    ),
    # brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s +10%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 10%-")),
    # Volume
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"),
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    ),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    # Mute Microphone
    Key(
        [],
        "XF86AudioMicMute",
        lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    ),
    # Toggle music player on or off
    Key(
        [],
        "XF86AudioPlay",
        lazy.spawn("/home/benny/scripts/mpc_toggle.sh toggle"),
    ),
    Key(
        [],
        "XF86AudioPlay",
        lazy.spawn("/home/benny/scripts/mpc_toggle.sh toggle"),
    ),
    Key(
        [],
        "XF86AudioNext",
        lazy.spawn("/home/benny/scripts/mpc_toggle.sh next"),
    ),
    Key(
        [],
        "XF86AudioPrev",
        lazy.spawn("/home/benny/scripts/mpc_toggle.sh prev"),
    ),
    # Application shortcut
    Key(
        [mod],
        "KP_Add",
        lazy.spawn("mate-calc"),
        desc="Launch calculator",
    ),
    Key([mod], "f", lazy.spawn(browser), desc="Firefox browser"),
    Key([mod], "c", lazy.spawn("librewolf"), desc="Librewolf browser"),
    Key([mod], "p", lazy.spawn("/home/benny/scripts/pwd.sh"), desc="Password manager"),
    Key([mod], "e", lazy.spawn("pcmanfm"), desc="File Manager"),
    Key([mod, "shift"], "w", lazy.spawn("nitrogen"), desc="Set Wallpaper"),
    # qtile controls
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle layout"),
    Key([mod], "b", lazy.hide_show_bar(), desc="Toggle bar"),
    Key([mod], "q", lazy.window.kill(), desc="Close Window"),
    # Switch between windows
    # Some layouts like 'monadtall' only need to use j/k to move
    # through the stack, but other layouts like 'columns' will
    # require all four directions h/j/k/l to move around.
    # Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
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
    font="MesloLGS Nerd Font Bold", fontsize=14, padding=4, fontweight="bold"
)
extension_defaults = widget_defaults.copy()


# Bar and Widgets
def init_widgets_list():
    return [
        widget.CurrentLayoutIcon(scale=0.7),
        widget.GroupBox(
            highlight_method="line",
            active="#f8f8f2",
            inactive="#AFB5D0",
            highlight_color=["#44475a", "#282a36"],
            this_current_screen_border="#ff79c6",
            rounded=False,
        ),
        widget.Spacer(),
        widget.Image(filename="~/.config/qtile/icons/microchip.png"),
        widget.CPU(
            format="{load_percent:>3.0f}%",
            width=50,
            padding=0,
            foreground="#2ECC71",
            mouse_callbacks={"Button1": lambda: qtile.spawn(terminal + " -e htop")},
            update_interval=2.0,
        ),
        widget.Image(filename="~/.config/qtile/icons/memory.png"),
        widget.Memory(
            format="{MemPercent:>3.0f}%",
            width=50,
            padding=0,
            foreground="#E74C3C",
            mouse_callbacks={"Button1": lambda: qtile.spawn(terminal + " -e htop")},
            update_interval=2.0,
        ),
        widget.Image(filename="~/.config/qtile/icons/hard-drive.png"),
        widget.Memory(
            format="{SwapPercent:>3.0f}%",
            width=50,
            padding=0,
            foreground="#F1C40F",
            update_interval=2.0,
        ),
        widget.Spacer(),
        widget.Wlan(
            interface="wlp1s0",
            format="  {essid:.5} ",
            disconnected_message="Disconnected",
            update_interval=10,
        ),
        widget.Volume(
            fmt="  {} ",
            foreground="#ECF0F1",
            mouse_callbacks={"Button1": lambda: qtile.spawn("pavucontrol")},
            volume_down_command="amixer -D pulse sset Master 5%-",
            volume_up_command="amixer -D pulse sset Master 5%+",
        ),
        widget.Backlight(
            backlight_name="amdgpu_bl1",  # Adjust based on your hardware
            format="󰃟 {percent:2.0%}",
            foreground="#ECF0F1",
        ),
        widget.Systray(),
        widget.Spacer(),
        widget.Clock(
            format=" %a, %d %b, %Y %H:%M:%S ",
            mouse_callbacks={"Button1": lambda: qtile.spawn("yad --calendar")},
            foreground="#ECF0F1",
        ),
    ]


screens = [
    Screen(
        wallpaper="/home/benny/Pictures/Island-Noon.jpg",
        wallpaper_mode="fill",
        top=bar.Bar(
            widgets=init_widgets_list(), size=24, background="#282a36", opacity=0.95
        ),
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
        Match(wm_class="galculator"),  # for calendar popup
    ]
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
wmname = "Qtile"
