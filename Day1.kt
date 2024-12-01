import java.io.File
import java.io.InputStream
import kotlin.math.abs

const val path = "data/day1.txt"

fun main() {
    val inputStream: InputStream = File(path).inputStream()
    val inputString = inputStream.bufferedReader().use { it.readText() }
    val inputLines = inputString.split('\n')

    val firstList = mutableListOf<Int>()
    val secondList = mutableListOf<Int>()

    for (line in inputLines) {
        val (x, y) = line.split("   ")

        val xInt = x.toInt()
        val yInt = y.toInt()

        firstList.add(xInt)
        secondList.add(yInt)
    }

    fun part1() {
        firstList.sort()
        secondList.sort()

        var total_sum = 0

        for ((x, y) in firstList zip secondList) {
            val difference = abs(x - y)

            total_sum += difference
        }

        println(total_sum)
    }

    fun part2() {
        var similarity_score = 0

        for (num in firstList) {
            val occurences = secondList.count { it == num }

            similarity_score += num * occurences
        }

        println(similarity_score)
    }

    part1()
    part2()
}