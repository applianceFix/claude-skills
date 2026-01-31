#!/usr/bin/env python3
"""
Export session data to HTML format.
Usage: python export.py [session-data.json] [output-base-name]

Note: Markdown generation is handled by Claude directly, not this script.
"""

import json
import base64
import sys
from pathlib import Path


def load_session(path: str) -> dict:
    """Load session data from JSON file."""
    with open(path, 'r') as f:
        return json.load(f)


def generate_html(session: dict, template_path: str) -> str:
    """Generate HTML from session data using template."""
    # Read template
    with open(template_path, 'r') as f:
        template = f.read()

    # Encode session data as base64
    session_b64 = base64.b64encode(json.dumps(session).encode()).decode()

    # Replace placeholder
    html = template.replace('{{SESSION_DATA}}', session_b64)

    return html


def main():
    # Parse arguments
    if len(sys.argv) < 2:
        session_path = Path(__file__).parent / 'session-data.json'
    else:
        session_path = Path(sys.argv[1])

    if len(sys.argv) < 3:
        output_base = Path(__file__).parent / 'session-export'
    else:
        output_base = Path(sys.argv[2])

    template_path = Path(__file__).parent / 'template.html'

    # Load session
    print(f"Loading session from: {session_path}")
    session = load_session(session_path)
    print(f"Loaded {len(session.get('messages', []))} messages")

    # Generate HTML
    if template_path.exists():
        html_output = output_base.with_suffix('.html')
        html = generate_html(session, template_path)
        with open(html_output, 'w') as f:
            f.write(html)
        print(f"Written: {html_output}")
    else:
        print(f"Template not found: {template_path}")
        sys.exit(1)

    print("Done!")


if __name__ == '__main__':
    main()
