//! In-place quicksort with a median-of-three pivot.

fn quicksort(items: &mut [i32]) {
    if items.len() <= 1 {
        return;
    }

    let pivot = median_of_three(items);
    let (mut left, mut right) = (0, items.len() - 1);

    while left <= right {
        while items[left] < pivot {
            left += 1;
        }
        while items[right] > pivot {
            right -= 1;
        }
        if left <= right {
            items.swap(left, right);
            left += 1;
            right -= 1;
        }
    }

    let split = left;
    quicksort(&mut items[..split]);
    quicksort(&mut items[split..]);
}

fn median_of_three(items: &[i32]) -> i32 {
    let (first, middle, last) = (items[0], items[items.len() / 2], items[items.len() - 1]);
    first.min(middle).max(first.max(middle).min(last))
}

fn main() {
    let mut data = [9, 4, 7, 1, 8, 2, 6, 3, 5];
    quicksort(&mut data);
    println!("{data:?}");
}

#[cfg(test)]
mod tests {
    use super::quicksort;

    #[test]
    fn sorts_in_place() {
        let mut data = [3, 1, 2];
        quicksort(&mut data);
        assert_eq!(data, [1, 2, 3]);
    }
}
