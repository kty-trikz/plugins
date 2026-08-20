#if defined _mewjam_color_included_
#endinput
#endif
#define _mewjam_color_included_

stock void TransColor(float percent, int color[3])
{
    if (percent < 0.0)
    {
        percent = 0.0;
    }
    if (percent > 100.0)
    {
        percent = 100.0;
    }

    int base = 32;
    int range = 255 - base;

    int red, green;
    if (percent < 50.0)
    {
        red = 255;
        green = base + RoundToNearest((percent / 50.0) * range);
    }
    else
    {
        green = 255;
        red = base + RoundToNearest(((100.0 - percent) / 50.0) * range);
    }

    color[0] = red;
    color[1] = green;
    color[2] = base;
}
