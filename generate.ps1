# draws text on the github contribution graph using backdated empty commits
# note: save this file as utf-8 with bom, otherwise windows powershell 5.1 breaks cyrillic

# make console output show cyrillic correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- settings ---------------------------------------------------------------
$perDay = 5          # commits per lit pixel (more commits = darker green square)
$branch = 'main'     # branch to push to
$dryRun = $false     # true = only count commits, do not create or push anything

# one entry = "year text"; latin and cyrillic can be mixed in one line
$entries = @(
  # "1989 HELLO WORLD"
  # "1990 IT WORKS!"
  # "1991 OOPS!"
  # "1992 I DID IT AGAIN"
  # "1993 DO NOT DEBUG!" # !!! not all text
  # "1994 JUST DO IT" # !!! wait for results
  # "1995 WORKS FOR ME"
  # "1996 DELETE PROD" # !!! not all text
  # "1997 NOT TODAY"
  # "1998 NO REGRETS"
  "1999 I KNOW BETTER"
  # "2000 STAY HUNGRY"
  # "2001 DREAM BIG"
  # "2002 MADONNA"
  # "2003 JESSICA LANGE"
  # "2004 KATHY BATES"
  # "2005 HEROES III"
  # "2006 SCHNELL!"
  # "2007 GUTEN MORGEN"
  # "2008 SCHEI3E!"
  # "2009 COCA COLA"
  # "2010 KNOTTY PINE!"
  # "2011 SEND NUDES"
  # "2012 SURPRISE B-CH"
  # "2013 STOP WAR!"
)

# --- font -------------------------------------------------------------------
# each glyph is 5 rows high, 'X' = lit pixel, '.' = empty; width may vary per glyph
$font = @{
 # latin
 'A'=@('.X.','X.X','XXX','X.X','X.X')
 'B'=@('XX.','X.X','XX.','X.X','XX.')
 'C'=@('XXX','X..','X..','X..','XXX')
 'D'=@('XX.','X.X','X.X','X.X','XX.')
 'E'=@('XXX','X..','XX.','X..','XXX')
 'F'=@('XXX','X..','XX.','X..','X..')
 'G'=@('XXX','X..','X.X','X.X','XXX')
 'H'=@('X.X','X.X','XXX','X.X','X.X')
 'I'=@('XXX','.X.','.X.','.X.','XXX')
 'J'=@('..X','..X','..X','X.X','XXX')
 'K'=@('X.X','X.X','XX.','X.X','X.X')
 'L'=@('X..','X..','X..','X..','XXX')
 'M'=@('X...X','XX.XX','X.X.X','X...X','X...X')
 'N'=@('X..X','XX.X','X.XX','X..X','X..X')
 'O'=@('XXX','X.X','X.X','X.X','XXX')
 'P'=@('XXX','X.X','XXX','X..','X..')
 'Q'=@('XXX','X.X','X.X','XXX','..X')
 'R'=@('XX.','X.X','XX.','X.X','X.X')
 'S'=@('XXX','X..','XXX','..X','XXX')
 'T'=@('XXX','.X.','.X.','.X.','.X.')
 'U'=@('X.X','X.X','X.X','X.X','XXX')
 'V'=@('X.X','X.X','X.X','X.X','.X.')
 'W'=@('X...X','X...X','X.X.X','XX.XX','X...X')
 'X'=@('X.X','X.X','.X.','X.X','X.X')
 'Y'=@('X.X','X.X','.X.','.X.','.X.')
 'Z'=@('XXX','..X','.X.','X..','XXX')

 # digits
 '0'=@('XXX','X.X','X.X','X.X','XXX')
 '1'=@('.X.','XX.','.X.','.X.','XXX')
 '2'=@('XXX','..X','XXX','X..','XXX')
 '3'=@('XXX','..X','XXX','..X','XXX')
 '4'=@('X.X','X.X','XXX','..X','..X')
 '5'=@('XXX','X..','XXX','..X','XXX')
 '6'=@('XXX','X..','XXX','X.X','XXX')
 '7'=@('XXX','..X','..X','.X.','.X.')
 '8'=@('XXX','X.X','XXX','X.X','XXX')
 '9'=@('XXX','X.X','XXX','..X','XXX')

 # punctuation
 '!'=@('X','X','X','.','X')
 '.'=@('.','.','.','.','X')
 ','=@('.','.','.','X','X')
 ':'=@('.','X','.','X','.')
 '?'=@('XXX','..X','.XX','...','.X.')
 '-'=@('...','...','XXX','...','...')

 # cyrillic letters that do NOT look like latin ones
 'Б'=@('XXX','X..','XX.','X.X','XX.')
 'Г'=@('XXX','X..','X..','X..','X..')
 'Д'=@('.XXX','.X.X','.X.X','XXXX','X..X')
 'Ж'=@('X.X.X','.XXX.','..X..','.XXX.','X.X.X')
 'З'=@('XXX','..X','.XX','..X','XXX')
 'И'=@('X..X','X..X','X.XX','XX.X','X..X')
 'Л'=@('.XXX','.X.X','.X.X','X..X','X..X')
 'П'=@('XXX','X.X','X.X','X.X','X.X')
 'У'=@('X.X','X.X','.XX','..X','XX.')
 'Ф'=@('.XXX.','X.X.X','X.X.X','.XXX.','..X..')
 'Ц'=@('X.X.','X.X.','X.X.','XXXX','...X')
 'Ч'=@('X.X','X.X','XXX','..X','..X')
 'Ш'=@('X.X.X','X.X.X','X.X.X','X.X.X','XXXXX')
 'Щ'=@('X.X.X.','X.X.X.','X.X.X.','XXXXXX','.....X')
 'Ъ'=@('XX..','.X..','.XX.','.X.X','.XX.')
 'Ы'=@('X...X','X...X','XXX.X','X.X.X','XXX.X')
 'Ь'=@('X..','X..','XX.','X.X','XX.')
 'Э'=@('XX.','..X','.XX','..X','XX.')
 'Ю'=@('X..X.','X.X.X','XXX.X','X.X.X','X..X.')
 'Я'=@('.XX','X.X','.XX','X.X','X.X')

 # ukrainian-only letters
 'Є'=@('.XX','X..','XX.','X..','.XX')
 'Ґ'=@('XXX','X.X','X..','X..','X..')
}

# cyrillic letters that look exactly like latin ones reuse the latin glyph
# note: no room for diacritics in 5 rows, so ё -> e, й -> и, ї -> i
$alias = @{
 'А'='A'; 'В'='B'; 'Е'='E'; 'Ё'='E'; 'К'='K'; 'М'='M'; 'Н'='H'; 'О'='O'
 'Р'='P'; 'С'='C'; 'Т'='T'; 'Х'='X'; 'І'='I'; 'Ї'='I'; 'Й'='И'
}
foreach ($k in $alias.Keys) { $font[$k] = $font[$alias[$k]] }

# --- sanity check -----------------------------------------------------------
# the script makes commits, so it must run inside a git repository
if ((git rev-parse --is-inside-work-tree 2>$null) -ne 'true') {
  throw 'run this script from inside a git repository'
}

# --- planning pass ----------------------------------------------------------
# first pass only builds the list of days to light up for every entry,
# so the total number of commits is known before the progress bar starts
$plan = New-Object System.Collections.ArrayList

foreach ($entry in $entries) {
  # split "1989 HELLO WORLD" into year and text
  $year, $text = $entry -split ' ', 2
  $year = [int]$year

  # build the bitmap as a list of 5-char columns (top to bottom)
  $cols = New-Object System.Collections.ArrayList
  foreach ($ch in $text.ToUpper().ToCharArray()) {
    # space = two empty columns
    if ($ch -eq ' ') { [void]$cols.Add('.....'); [void]$cols.Add('.....'); continue }
    $g = $font["$ch"]
    if (-not $g) { Write-Warning "no glyph for '$ch', skipped"; continue }
    # transpose glyph rows into columns
    for ($x = 0; $x -lt $g[0].Length; $x++) {
      $c = ''
      for ($y = 0; $y -lt 5; $y++) { $c += $g[$y][$x] }
      [void]$cols.Add($c)
    }
    # one empty column between letters
    [void]$cols.Add('.....')
  }
  # drop trailing empty columns so centering is exact
  while ($cols.Count -gt 0 -and $cols[$cols.Count-1] -eq '.....') { $cols.RemoveAt($cols.Count-1) }

  # a year has at most 53 week columns on the graph
  if ($cols.Count -gt 53) {
    Write-Warning "$year '$text': needs $($cols.Count) columns, max is 53. skipped."
    continue
  }

  # graph starts on the sunday on or before jan 1; rows are mon..fri (offset +1)
  $jan1   = [datetime]"$year-01-01"
  $start  = $jan1.AddDays(-[int]$jan1.DayOfWeek)
  # center the text horizontally
  $offset = [math]::Floor((53 - $cols.Count) / 2)

  # collect every day that has to be lit for this entry
  $days = New-Object System.Collections.ArrayList
  for ($i = 0; $i -lt $cols.Count; $i++) {
    for ($y = 0; $y -lt 5; $y++) {
      if ($cols[$i][$y] -eq 'X') {
        $d = $start.AddDays(($offset + $i) * 7 + $y + 1)
        # skip days that spill into the neighbouring year
        if ($d.Year -ne $year) { continue }
        [void]$days.Add($d)
      }
    }
  }

  # remember the entry together with its days
  [void]$plan.Add([pscustomobject]@{ Year = $year; Text = $text; Days = $days })
}

# total commits across all entries = lit days * commits per day
$litDays = 0
foreach ($p in $plan) { $litDays += $p.Days.Count }
$total = $litDays * $perDay

# --- main loop --------------------------------------------------------------
$done    = 0     # commits made so far
$lastPct = -1    # last percent shown, used to avoid redrawing the bar needlessly
$sw      = [System.Diagnostics.Stopwatch]::StartNew()   # for the eta estimate

foreach ($p in $plan) {
  $n = 0   # commits made for this entry

  foreach ($d in $p.Days) {
    if (-not $dryRun) {
      # backdate both author and committer so github places the commit on that day
      $iso = $d.ToString("yyyy-MM-dd") + "T12:00:00"
      $env:GIT_AUTHOR_DATE = $iso
      $env:GIT_COMMITTER_DATE = $iso
    }

    for ($k = 0; $k -lt $perDay; $k++) {
      # empty commits: no file changes needed
      if (-not $dryRun) { git commit --allow-empty -q -m "$($p.Year) $($p.Text)" }
      $done++
      $n++

      # redraw the bar only when the whole percent changes (and on the last commit)
      $pct = [int][math]::Floor(100 * $done / $total)
      if ($pct -ne $lastPct -or $done -eq $total) {
        $lastPct = $pct

        # eta = average time per commit * commits left
        $eta = ''
        if ($done -gt 0 -and $done -lt $total) {
          $secLeft = [int]($sw.Elapsed.TotalSeconds / $done * ($total - $done))
          $eta = ", eta {0:mm\:ss}" -f [timespan]::FromSeconds($secLeft)
        }

        Write-Progress -Activity "drawing graph text" `
          -Status "$($p.Year) '$($p.Text)': $done / $total commits ($pct%)$eta" `
          -PercentComplete $pct
      }
    }
  }

  # progress bar is transient, so print a permanent line per entry
  Write-Host "$($p.Year) '$($p.Text)': $n commits"
}

# close the progress bar
Write-Progress -Activity "drawing graph text" -Completed
Write-Host ("done: {0} commits in {1:mm\:ss}" -f $done, $sw.Elapsed)

# clean up env vars so they do not leak into later git commands
Remove-Item Env:GIT_AUTHOR_DATE, Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

# publish everything at once
if (-not $dryRun) { git push origin $branch }
