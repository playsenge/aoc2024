use std::fs::File;
use std::io::{BufReader, BufRead};
use std::collections::HashMap;
use std::hash::Hash;

const PATH: &str = "data/day5.txt";

struct Counter {}

impl Counter {
  fn from<T>(vector: &Vec<T>) -> HashMap<T, u32> where T: Eq + Hash + Clone {
    let mut map: HashMap<T, u32> = HashMap::new();

    for key in vector {
      *map.entry(key.clone()).or_insert(0) += 1;
    }
    
    map
  }
}

fn read_data(ordering_rules: &mut HashMap<u32, Vec<u32>>, updates: &mut Vec<Vec<u32>>) {
  let file = File::open(PATH).unwrap();
  let reader = BufReader::new(file);
  
  let mut page_ordering = true;
  
  for raw_line in reader.lines() {
    let line = raw_line.unwrap();

    if line == "" {
      page_ordering = false;
      continue;
    }

    match page_ordering {
      true => {
        let line_split = line.split("|").collect::<Vec<&str>>();
        let [x, y] = [line_split[0], line_split[1]]
            .map(str::parse::<u32>)
            .map(|arg| arg.unwrap());

        // Storing them in opposite order - the y entry on iteration is checked to
        // be after all of the x's
        if !ordering_rules.contains_key(&y) {
          ordering_rules.insert(y, Vec::new());
        }

        ordering_rules.get_mut(&y).unwrap().push(x);
      },
      false => {
        let line_split = line.split(",")
          .collect::<Vec<&str>>()
          .into_iter()
          .map(str::parse::<u32>)
          .map(|arg| arg.unwrap())
          .collect::<Vec<u32>>();

        updates.push(line_split);
      },
    };
  }
}

fn is_correctly_placed(ordering_rules: &mut HashMap<u32, Vec<u32>>, counter: &HashMap<u32, u32>, vector: &Vec<u32>, element: u32) -> bool {
  let index = vector.iter().position(|&x| x == element).unwrap();
  let must_be_earlier = ordering_rules.entry(element).or_default();
  let earlier_page_numbers = &vector[0..index];

  for need_earlier in &mut *must_be_earlier {
    if !earlier_page_numbers.contains(&need_earlier) && counter.contains_key(&need_earlier) {
      return false;
    }
  }

  true
}

fn main() {
  let mut ordering_rules: HashMap<u32, Vec<u32>> = HashMap::new();
  let mut updates: Vec<Vec<u32>> = Vec::new();

  read_data(&mut ordering_rules, &mut updates);

  let mut part1: u32 = 0;
  let mut part2: u32 = 0;

  for update in updates {
    let counter = Counter::from(&update);
    let mut incorrectly_ordered: Vec<u32> = Vec::new();
    
    for (i, element) in update.iter().enumerate() {
      let must_be_earlier = ordering_rules.entry(*element).or_default();
      let earlier_page_numbers = &update[0..i];

      for need_earlier in &mut *must_be_earlier {
        if !earlier_page_numbers.contains(&need_earlier) && counter.contains_key(&need_earlier) {
          incorrectly_ordered.push(*need_earlier);
        }
      }
    }

    if incorrectly_ordered.is_empty() { 
      part1 += update[update.len() / 2];
    } else {
      // Insertion Sort style - iterate, when an element is incorrectly placed, move it to the right until it's right :)
      let mut fixed_update = update.clone(); // is this freaking unity, FixedUpdate lol

      // Enough passes till it doesn't change'
      loop {
        let mut did_changes = false;
        
        for i in 0..fixed_update.len() {
          let original_element = fixed_update[i].clone();
          let mut j = i;
          
          while !is_correctly_placed(&mut ordering_rules, &counter, &fixed_update, original_element) && j <= fixed_update.len() {
            did_changes = true;
            fixed_update.swap(j, j + 1);
            j += 1;
          }
        }
        
        if !did_changes { break }
      }
      
      part2 += fixed_update[fixed_update.len() / 2];
    }
  }

  println!("{}", part1);
  println!("{}", part2);
}
