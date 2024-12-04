package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func IsXmasForward(slice []byte) bool {
	return string(slice) == "XMAS"
}

func IsXmasBackward(slice []byte) bool {
	return string(slice) == "SAMX"
}

func CrossShapeCmp(s1 string, s2 string) bool {
	// "X.X" + ".X." + "X.X"
	return s1[0] == s2[0] && s1[2] == s2[2] && s1[4] == s2[4] && s1[6] == s2[6] && s1[8] == s2[8]
}

type Direction int

const (
	horizontalForward     Direction = iota
	horizontalBackward    Direction = iota
	verticalForward       Direction = iota
	verticalBackward      Direction = iota
	diagonalRightForward  Direction = iota
	diagonalRightBackward Direction = iota
	diagonalLeftForward   Direction = iota
	diagonalLeftBackward  Direction = iota
)

type Coordinate struct {
	startx    int
	starty    int
	direction Direction
}

func main() {
	file, err := os.Open("data/day4.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	reader := bufio.NewReader(file)
	lines := [][]byte{}

	for {
		lineRaw, err := reader.ReadString('\n')
		line := strings.Trim(lineRaw, "\n")

		bytes := []byte{}

		for _, ch := range strings.Split(line, "") {
			bytes = append(bytes, ch[0])
		}

		lines = append(lines, bytes)

		if err != nil {
			break
		}
	}

	rows := len(lines)
	cols := len(lines[0])

	coordinates := map[Coordinate]bool{}

	// Horizontal
	for i := 0; i < rows; i++ {
		line := lines[i]

		for j := 0; j < cols - 3; j++ {
			slice := line[j : j+4]

			if IsXmasForward(slice) {
				coordinate := Coordinate{startx: j, starty: i, direction: horizontalForward}
				coordinates[coordinate] = true
			}

			if IsXmasBackward(slice) {
				coordinate := Coordinate{startx: j, starty: i, direction: horizontalBackward}
				coordinates[coordinate] = true
			}
		}
	}

	// Vertical
	for i := 0; i < cols; i++ {
		// line := lines[wildcard][i]
		line := []byte{}

		for j := 0; j < rows; j++ {
			line = append(line, lines[j][i])
		}

		for j := 0; j < cols - 3; j++ {
			slice := line[j : j+4]

			if IsXmasForward(slice) {
				coordinate := Coordinate{startx: i, starty: j, direction: verticalForward}
				coordinates[coordinate] = true
			}

			if IsXmasBackward(slice) {
				coordinate := Coordinate{startx: i, starty: j, direction: verticalBackward}
				coordinates[coordinate] = true
			}
		}
	}

	// Diagonal - every single point
	for i := 0; i < rows; i++ {
		for j := 0; j < cols; j++ {
			// top-left ==> bottom-right -- diagonalRightForward & diagonalRightBackward
			line := []byte{}

			i_searcher := i
			j_searcher := j

			for i_searcher >= 0 && i_searcher < rows && j_searcher >= 0 && j_searcher < cols && len(line) < 4 {
				line = append(line, lines[i_searcher][j_searcher])

				i_searcher++
				j_searcher++
			}

			if len(line) == 4 {
				if IsXmasForward(line) {
					coordinate := Coordinate{startx: i, starty: j, direction: diagonalRightForward}
					coordinates[coordinate] = true
				}
	
				if IsXmasBackward(line) {
					coordinate := Coordinate{startx: i, starty: j, direction: diagonalRightBackward}
					coordinates[coordinate] = true
				}
			}

			// top-right ==> bottom-left -- diagonalLeftForward & diagonalLeftBackward
			line = []byte{}

			i_searcher = i
			j_searcher = j

			for i_searcher >= 0 && i_searcher < rows && j_searcher >= 0 && j_searcher < cols && len(line) < 4 {
				line = append(line, lines[i_searcher][j_searcher])

				i_searcher++
				j_searcher--
			}

			if len(line) == 4 {
				if IsXmasForward(line) {
					coordinate := Coordinate{startx: i, starty: j, direction: diagonalLeftForward}
					coordinates[coordinate] = true
				}
	
				if IsXmasBackward(line) {
					coordinate := Coordinate{startx: i, starty: j, direction: diagonalLeftBackward}
					coordinates[coordinate] = true
				}
			}
		}
	}

	part2 := 0

	for i := 0; i < rows - 2; i++ {
		for j := 0; j < cols - 2; j++ {
			cross := ""

			for ii := i; ii < i + 3; ii++ {
				for jj := j; jj < j + 3; jj++ {
					cross += string(lines[ii][jj])
				}
			}

			if CrossShapeCmp(cross, "M.S" +
											 				".A." +
											 				"M.S") {
				part2++
			}

			if CrossShapeCmp(cross, "S.S" +
															".A." +
															"M.M") {
				part2++
			}

			if CrossShapeCmp(cross, "M.M" +
															".A." +
															"S.S") {
				part2++
			}
			
			if CrossShapeCmp(cross, "S.M" +
															".A." +
															"S.M") {
				part2++
			}
		}
	}
	
	fmt.Println(len(coordinates))
	fmt.Println(part2)
}
