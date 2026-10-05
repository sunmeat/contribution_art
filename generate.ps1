$entries = @(
  "1989 HELLO WORLD!"
  "1990 IT WORKS!"
  "1991 OOPS!"
  "1992 I DID IT AGAIN"
  "1993 SEND NUDES"
  "1994 OOPS!"
  "1995 MADONNA"
  "1996 DO NOT DEBUG!"
  "1997 WORKS SOMEHOW"
  "1998 LADY GAGA"
  "1999 WORKS FOR ME"
  "2000 NOT TODAY"
  "2001 SCHNELL!"
  "2002 GUTEN MORGEN"
  "2003 COCA COLA"
  "2004 KNOTTY PINE!"
  "2005 NO REGRETS"
  "2006 I KNOW BETTER"
  "2007 WHO CARES"
  "2008 SURPRISE B-TH"
  "2009 JESSICA LANGE"
  "2010 KATHY BATES"
  "2011 HEROES III"
  "2012 SCHEI3E!"
  "2013 DELETE PROD"
)
$perDay = 5

$font = @{
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
 '!'=@('X','X','X','.','X')
 '.'=@('.','.','.','.','X')
 '?'=@('XXX','..X','.XX','...','.X.')
 '-'=@('...','...','XXX','...','...')
}

foreach ($entry in $entries) {
  $year, $text = $entry -split ' ', 2
  $year = [int]$year

  $cols = New-Object System.Collections.ArrayList
  foreach ($ch in $text.ToUpper().ToCharArray()) {
    if ($ch -eq ' ') { [void]$cols.Add('.....'); [void]$cols.Add('.....'); continue }
    $g = $font["$ch"]
    if (-not $g) { Write-Warning "Нет символа '$ch', пропущен"; continue }
    for ($x = 0; $x -lt $g[0].Length; $x++) {
      $c = ''
      for ($y = 0; $y -lt 5; $y++) { $c += $g[$y][$x] }
      [void]$cols.Add($c)
    }
    [void]$cols.Add('.....')
  }
  while ($cols.Count -gt 0 -and $cols[$cols.Count-1] -eq '.....') { $cols.RemoveAt($cols.Count-1) }

  if ($cols.Count -gt 53) {
    Write-Warning "$year '$text': нужно $($cols.Count) колонок, максимум 53. Пропущено."
    continue
  }

  $jan1   = [datetime]"$year-01-01"
  $start  = $jan1.AddDays(-[int]$jan1.DayOfWeek)  
  $offset = [math]::Floor((53 - $cols.Count) / 2) 
  $n = 0

  for ($i = 0; $i -lt $cols.Count; $i++) {
    for ($y = 0; $y -lt 5; $y++) {
      if ($cols[$i][$y] -eq 'X') {
        $d = $start.AddDays(($offset + $i) * 7 + $y + 1) 
        if ($d.Year -ne $year) { continue }
        $iso = $d.ToString("yyyy-MM-dd") + "T12:00:00"
        $env:GIT_AUTHOR_DATE = $iso
        $env:GIT_COMMITTER_DATE = $iso
        1..$perDay | ForEach-Object { git commit --allow-empty -q -m "$year $text" }
        $n += $perDay
      }
    }
  }
  Write-Host "$year '$text': $n коммитов"
}
Remove-Item Env:GIT_AUTHOR_DATE, Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

git push origin master
