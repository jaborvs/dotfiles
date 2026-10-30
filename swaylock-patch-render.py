#!/usr/bin/env python3

content = open('render.c').read()

# Patch 1: clock position -3px
content = content.replace(
    '(fe_l1.height / 2 - fe_l1.descent) - arc_radius / 10.0f;',
    '(fe_l1.height / 2 - fe_l1.descent) - arc_radius / 10.0f - 3.0f;'
)
content = content.replace(
    '(fe_l2.height / 2 - fe_l2.descent) + arc_radius / 3.5f;',
    '(fe_l2.height / 2 - fe_l2.descent) + arc_radius / 3.5f - 3.0f;'
)

# Patch 2: date brackets white, date content in accent #afa193
old = '\t\t\tcairo_move_to(cairo, x_l2, y_l2);\n\t\t\tcairo_show_text(cairo, text_l2);'

null_term = 'inner[inner_len] = ' + chr(39) + chr(92) + chr(48) + chr(39) + ';'

new = '\n'.join([
    '\t\t\tcairo_move_to(cairo, x_l2, y_l2);',
    '\t\t\t/* Draw brackets in text color, date content in accent */',
    "\t\t\tif (strlen(text_l2) > 4 && text_l2[0] == '[' && text_l2[strlen(text_l2)-1] == ']') {",
    '\t\t\t\tchar prefix[3], suffix[3], inner[128];',
    '\t\t\t\tsnprintf(prefix, sizeof(prefix), "[ ");',
    '\t\t\t\tsize_t inner_start = 2;',
    '\t\t\t\tsize_t inner_end = strlen(text_l2) - 2;',
    '\t\t\t\tsize_t inner_len = inner_end - inner_start;',
    '\t\t\t\tif (inner_len < sizeof(inner)) {',
    '\t\t\t\t\tstrncpy(inner, text_l2 + inner_start, inner_len);',
    '\t\t\t\t\t' + null_term,
    '\t\t\t\t\tsnprintf(suffix, sizeof(suffix), " ]");',
    '\t\t\t\t\tcairo_show_text(cairo, prefix);',
    '\t\t\t\t\tcairo_set_source_u32(cairo, 0xafa193ff);',
    '\t\t\t\t\tcairo_show_text(cairo, inner);',
    '\t\t\t\t\tcairo_set_source_u32(cairo, state->args.colors.text.input);',
    '\t\t\t\t\tcairo_show_text(cairo, suffix);',
    '\t\t\t\t} else {',
    '\t\t\t\t\tcairo_set_source_u32(cairo, 0xafa193ff);',
    '\t\t\t\t\tcairo_show_text(cairo, text_l2);',
    '\t\t\t\t\tcairo_set_source_u32(cairo, state->args.colors.text.input);',
    '\t\t\t\t}',
    '\t\t\t} else {',
    '\t\t\t\tcairo_set_source_u32(cairo, 0xafa193ff);',
    '\t\t\t\tcairo_show_text(cairo, text_l2);',
    '\t\t\t\tcairo_set_source_u32(cairo, state->args.colors.text.input);',
    '\t\t\t}',
])

assert old in content, 'ERROR: date drawing pattern not found in render.c'
content = content.replace(old, new)

raw = content.encode('utf-8')
assert b'\x00' not in raw, 'ERROR: null byte found in patched output'

open('render.c', 'w').write(content)
print('All patches applied cleanly.')
