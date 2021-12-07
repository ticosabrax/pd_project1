# UFO Sightings

Este reposotorio contiene los archivos necesarios para ejecutar la aplicación (dashboard)
desarrollada con shiny y shinydashboard.

La aplicación consiste en un Dashboard que permite ver la información registrada
sobre los avistamientos de ovnis que han sido registrados en los Estados Unidos
entre los años 1969 y 2021.

### Uso del Dashboard
0. Acceder a la aplicación, la cual está publicada en https://esaban.shinyapps.io/pd_project1/

1. Se debe cargar el dataset para que el dashboard pueda funcionar. La opción de carga
se encuenta en el dashboard. El dataset está almacenado en la carpeta **data** de este
repositorio y el peso aproximado son 9MB. Es importante indicar que el dashboard está
desarrollado para la estructura del archivo indicado.

2. En cada opción del dashboard se pueden explorar las distintas interacciones con los
datos.

3. La opción **UFO Sighting by shape** implementa el paso de parámetros, para testear
esta dinámica puede probar con:

- https://esaban.shinyapps.io/pd_project1/?shape=flash,oval,rectangle
- https://esaban.shinyapps.io/pd_project1/?shape=flash,oval,rectangle&state=CA,NY

### Desarrolladores

Este proyecto fue desarrollado por Edgar Sabán y Henry Barrientos.


