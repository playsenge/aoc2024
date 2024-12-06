from std/sequtils import toSeq
from std/enumerate import enumerate
from std/strformat import fmt
import std/sets

type 
  Direction = enum
    left, right, up, down
  VisitedCoordinate = object
    x: int
    y: int
    direction: Direction

proc readInput(): seq[seq[char]] =
  let file = open("data/day6.txt")
  defer: file.close()

  var line: string
  var list: seq[seq[char]] = @[]

  while file.readLine(line):
    list.add(toSeq(line.items))

  return list

proc xDiff(dir: Direction): int =
  result = case dir:
    of Direction.up:
      -1
    of Direction.down:
      1
    of Direction.left, Direction.right:
      0

proc yDiff(dir: Direction): int =
  result = case dir:
    of Direction.left:
      -1
    of Direction.right:
      1
    of Direction.up, Direction.down:
      0

proc newDirection(dir: Direction): Direction = 
  result = case dir:
    of Direction.up:
      Direction.right
    of Direction.down:
      Direction.left
    of Direction.left:
      Direction.up
    of Direction.right:
      Direction.down

proc prettyPrint(x: seq[seq[char]]) =
  for row in x:
    echo cast[string](row)
  echo '-'

proc walkaround(data_original: seq[seq[char]], startingX: int, startingY: int): int =
  var data = data_original.deepCopy()
  
  var visited = initHashSet[VisitedCoordinate]()
  var visitedPositions = initHashSet[array[0..1, int]]()

  var
    currentDirection: Direction = Direction.up
    x: int = startingX
    y: int = startingY
    
  while true:
    let nextX = x + xDiff(currentDirection)
    let nextY = y + yDiff(currentDirection)

    if visited.contains(VisitedCoordinate(x: nextX, y: nextY, direction: currentDirection)):
      return -1

    var spot: char
    try:
      spot = data[nextX][nextY]
      if spot != '#':
        data[nextX][nextY] = 'X'
    except:
      break

    case spot:
      of '.', 'X':
        # Move
        x = nextX
        y = nextY
      of '#':
        # Bumped into obstacle
        currentDirection = newDirection(currentDirection)
        continue
      else:
        discard

    visited.incl(VisitedCoordinate(x: x, y: y, direction: currentDirection))
    visitedPositions.incl([x, y])
    
  return visitedPositions.len

let data = readInput()

var
  startingX: int = -1
  startingY: int = -1

  # Find the guard
block find:
  for i, row in enumerate(data):
    for j, spot in enumerate(row):
      if spot == '^':
        startingX = i
        startingY = j
        
        break find

echo walkaround(data, startingX, startingY)

var part2 = 0

for i in countup(0, data.len - 1):
  for j in countup(0, data[0].len - 1):
    var data_copy = data.deepCopy()
    data_copy[i][j] = '#'

    if walkaround(data_copy, startingX, startingY) == -1:
      part2 += 1

echo part2
