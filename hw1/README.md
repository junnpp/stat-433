# STAT-433

**Q1.How many flights have a missing dep_time? What other variables are missing? What might these rows represent?**

```
flights %>% count(is.na(dep_time))
```
![](p1-image.png)

| is.na(dep_time) | n |
| :----------- | :----------- |
| FALSE      | 328521       |
| TRUE   | 8255        |

Looking at the table, there

