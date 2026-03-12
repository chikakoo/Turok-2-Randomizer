from argparse import Namespace
from CommonClient import CommonContext, server_loop, gui_enabled
import asyncio

class Turok2Context(CommonContext):
    game = "Turok 2"

    def __init__(self, server_address, password):
        super().__init__(server_address, password)

async def main(args: Namespace) -> None:
    ctx = Turok2Context(args.url, None)

    if gui_enabled:
        ctx.run_gui()

    await server_loop(ctx)