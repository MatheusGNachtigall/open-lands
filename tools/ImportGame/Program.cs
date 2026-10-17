// Extracts a GOG Lands of Lore installation (GAME.DAT and the loose files) the way the setup page does.
//   dotnet run --project tools/ImportGame -- GOG_FOLDER DESTINATION
// Prints the folder with the PAK files (DESTINATION/dataRoot).
using System;
using System.IO;
using LolHost;

if (args.Length != 2) { Console.Error.WriteLine("usage: ImportGame GOG_FOLDER DESTINATION"); return 2; }
try
{
    int last = -1;
    var (files, volumeId, dataRoot) = ImportGame.importGame(args[0], args[1], (done, total, name) =>
    {
        int pct = total > 0 ? done * 100 / total : 0;
        if (pct / 10 != last / 10) { last = pct; Console.Error.WriteLine($"import {pct}% {name}"); }
    });
    Console.Error.WriteLine($"imported {files} files from {volumeId}");
    Console.WriteLine(Path.GetFullPath(Path.Combine(args[1], dataRoot)));
    return 0;
}
catch (Exception e) { Console.Error.WriteLine($"import failed: {e.Message}"); return 1; }
