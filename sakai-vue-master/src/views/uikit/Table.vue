<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';
import Dropdown from 'primevue/dropdown';

const toast = useToast();
</script>

<script>
import * as XLSX from 'xlsx';
import axios from 'axios';
import { ref } from 'vue';

export default {
    data() {
        return {
            oneReport: [],
            reporte1: null,
            twoReport: null,
            reporte3: null,
            reporte4: null,
            reporte5: null,
            reporte6: null,
            dropdownValue: null, // Valor seleccionado en el Dropdown
            dropdownOptions: [1], // Opciones para el Dropdown
        };
    },
    mounted() {
        //this.reportOne();
        this.reportTwo();
        this.reportThree();
        this.reportFour();
        this.reportFive();
        this.reportSix();
        // this.cargarDatosDeLaAPI();
        const row = { numlote: 123 }; // Reemplaza esto con tus datos reales
        this.cargarDatosDeLaAPI(row);
    },
    methods: {
        async reportOne() {
            try {
                // Hacer la petición POST a la API con el número de lote seleccionado
                const response = await axios.post('http://localhost:3000/reporteUno', {
                    numlote: this.dropdownValue.name,  // Asignar el valor seleccionado a numlote
                });

                console.log('Respuesta de la API:', response.data);
                this.oneReport = response.data;

                // La respuesta del servidor estará en response.data
                console.log('Datos de la APIiii:', this.oneReport);
            } catch (error) {
                // Manejar errores, por ejemplo, mostrando un mensaje de error
                console.error('Error al consumir la API:', error);
            }
        },


        exportarExcelReporteOne() {
            const ws = XLSX.utils.json_to_sheet(this.oneReport);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Reporte Uno');
            XLSX.writeFile(wb, 'reporteUno.xlsx');
        },
        async reportTwo() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/reporteDos',
                responseType: 'JSON'
            }).then((response) => {
                console.log('datos que llegan', response.data);
                this.twoReport = JSON.parse(response.data);
                console.log(this.twoReport);
            });
        },
        exportarExcelReporteDos() {
            const ws = XLSX.utils.json_to_sheet(this.twoReport);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Reporte Dos');
            XLSX.writeFile(wb, 'reporteDos.xlsx');
        },
        async reportThree() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/reporteTres',
                responseType: 'JSON'
            }).then((response) => {
                console.log('datos que llegan', response.data);
                this.threeReport = JSON.parse(response.data);
                console.log(this.twoReport);
            });
        },
        exportarExcelReporteTres() {
            const ws = XLSX.utils.json_to_sheet(this.threeReport);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Reporte Tres');
            XLSX.writeFile(wb, 'reporteTres.xlsx');
        },
        async reportFour() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/reporteCuatro',
                responseType: 'JSON'
            }).then((response) => {
                console.log('datos que llegan', response.data);
                this.FourReport = JSON.parse(response.data);
                console.log(this.twoReport);
            });
        },
        exportarExcelReporteFour() {
            const ws = XLSX.utils.json_to_sheet(this.FourReport);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Reporte Cuatro');
            XLSX.writeFile(wb, 'reporteCuatro.xlsx');
        },
        async reportFive() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/reporteCinco',
                responseType: 'JSON'
            }).then((response) => {
                console.log('datos que llegan', response.data);
                this.FiveReport = JSON.parse(response.data);
                console.log(this.twoReport);
            });
        },
        exportarExcelReporteFive() {
            const ws = XLSX.utils.json_to_sheet(this.FiveReport);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Reporte Cinco');
            XLSX.writeFile(wb, 'reporteCinco.xlsx');
        },
        async reportSix() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/reporteSeis',
                responseType: 'JSON'
            }).then((response) => {
                console.log('datos que llegan', response.data);
                this.SixReport = JSON.parse(response.data);
                console.log(this.twoReport);
            });
        },
        exportarExcelReporteSix() {
            const ws = XLSX.utils.json_to_sheet(this.SixReport);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Reporte Seis');
            XLSX.writeFile(wb, 'reporteSeis.xlsx');
        },
        async cargarDatosDeLaAPI(row) {
            try {
                // Simulando la carga de datos desde la API
                const response = await axios.get('http://localhost:3000/getLotes');
                console.log('datos que llegan en el get', response.data);

                // Obtener todos los valores de 'numlote'
                this.dropdownOptions = response.data.map(item => ({ name: item.numlote }));

                console.log(this.dropdownOptions);
            } catch (error) {
                console.error('Error al cargar los datos de la API:', error);
            }
        },
    }
};
</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3><b>REPORTES SOLICITADOS</b></h3>
                <Toast />
                <hr />
                <div class="card">
                    <!-- SECCIÓN DEL PRIMER REPORTE -->
                    <h4><b>PRIMER REPORTE</b></h4>
                    <hr />
                    <h6><b>Mostrar el timpo que dura el proceso de un determinado lote de café, desde la recolección hasta
                            el
                            secado.</b></h6>
                    <hr />
                    <Toolbar class="col-8">
                        <template v-slot:start && #body="slotProps">
                            <Dropdown v-model="dropdownValue" :options="dropdownOptions" optionLabel="name"
                                placeholder="Seleccionar Un Lote " />
                            <hr />
                            <hr />
                            <hr />
                            <Button label="Consultar" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                @click="reportOne()"></Button>
                            <Button label="Exportar Excel" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                @click="exportarExcelReporteOne()"></Button>
                        </template>
                    </Toolbar>
                    <hr />
                    <DataTable v-bind="value" :value="oneReport" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} registros."
                        responsiveLayout="scroll">
                        <Column field="numlote" header="Número de lote" :sortable="true" style="width: 30px"></Column>
                        <Column field="fecharecoleccion" header="Fecha de recolección" style="width: 40px"></Column>
                        <Column field="fechadespulpado" header="Fecha de despulpado" style="width: 40px"></Column>
                        <Column field="fechafermentacioninicio" header="Fecha inicio fermentacion" style="width: 60px">
                        </Column>
                        <Column field="fechafermentacionfin" header="Fecha fin de fermentacion" style="width: 80px">
                        </Column>
                        <Column field="fechasecadoinicio" header="Fecha Inicio de secado" style="width: 80px"></Column>
                        <Column field="fechasecadofin" header="Fecha fin de secado" style="width: 80px"></Column>
                    </DataTable>
                </div>
                <div class="card">
                    <!-- SECCIÓN DEL SEGUNDO REPORTE -->
                    <h4><b>SEGUNDO REPORTE</b></h4>
                    <hr />
                    <h6><b>Mostrar los datos de la fase en la que se encuentra cada lote de café.</b></h6>
                    <hr />
                    <Toolbar class="col-2">
                        <template v-slot:start && #body="slotProps">
                            <div class="my-2">
                                <Button label="Exportar Excel" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                    @click="exportarExcelReporteDos()"></Button>
                            </div>
                        </template>
                    </Toolbar>
                    <hr />
                    <DataTable v-bind="value" :value="twoReport" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} registros."
                        responsiveLayout="scroll">
                        <Column field="numlote" header="Número de lote" :sortable="true" style="width: 30px"></Column>
                        <Column field="estadorecoleccion" header="Estado de la recolección" style="width: 40px"></Column>
                        <Column field="estadodespulpado" header="Estado del despulpado" style="width: 40px"></Column>
                        <Column field="estadolavado" header="Estado del lavado" style="width: 60px"></Column>
                        <Column field="estadosecado" header="Estado del secado" style="width: 80px"></Column>
                    </DataTable>
                </div>
                <div class="card">
                    <!-- SECCIÓN DEL TERCER REPORTE -->
                    <h4><b>TERCER REPORTE</b></h4>
                    <hr />
                    <h6><b>Mostrar los tanques y cuarto disponibles en cualquier momento.</b></h6>
                    <hr />
                    <Toolbar class="col-3">
                        <template v-slot:start && #body="slotProps">
                            <div class="my-2">
                                <Button label="Exportar Excel" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                    @click="exportarExcelReporteTres()"></Button>
                            </div>
                        </template>
                    </Toolbar>
                    <hr />
                    <DataTable v-bind="value" :value="threeReport" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} registros."
                        responsiveLayout="scroll">
                        <Column field="idrecurso" header="ID del tanque" :sortable="true" style="width: 30px"></Column>
                        <Column field="estadorecurso" header="Estado" style="width: 40px"></Column>
                        <Column field="idcuarto" header="ID del cuarto" style="width: 60px"></Column>
                        <Column field="estadocuarto" header="Estado" style="width: 80px"></Column>
                    </DataTable>
                </div>
                <div class="card">

                    <!-- SECCIÓN DEL CUARTO REPORTE -->
                    <h4><b>CUARTO REPORTE</b></h4>
                    <hr />
                    <h6><b>Mostrar cual es el mes en el que má se ha recolectado más cantidad de café.</b></h6>
                    <hr />
                    <Toolbar class="col-3">
                        <template v-slot:start && #body="slotProps">
                            <div class="my-2">
                                <Button label="Exportar Excel" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                    @click="exportarExcelReporteFour()"></Button>
                            </div>
                        </template>
                    </Toolbar>
                    <hr />
                    <DataTable v-bind="value" :value="FourReport" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} registros."
                        responsiveLayout="scroll">
                        <Column field="mes" header="Mes" :sortable="true" style="width: 30px"></Column>
                        <Column field="totalcaferecolectado" header="Cantidad recolectada" style="width: 40px"></Column>
                    </DataTable>
                </div>
                <div class="card">
                    <!-- SECCIÓN DEL QUINTO REPORTE -->
                    <h4><b>QUINTO REPORTE</b></h4>
                    <hr />
                    <h6><b>Mostrar cual es el tipo de café que se ha recolectado más en un año (verde, maduro, sobremaduro y
                            seco).</b></h6>
                    <hr />
                    <Toolbar class="col-3">
                        <template v-slot:start && #body="slotProps">
                            <div class="my-2">
                                <Button label="Exportar Excel" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                    @click="exportarExcelReporteFive()"></Button>
                            </div>
                        </template>
                    </Toolbar>
                    <hr />
                    <DataTable v-bind="value" :value="FiveReport" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} registros."
                        responsiveLayout="scroll">
                        <Column field="anio" header="Año" :sortable="true" style="width: 30px"></Column>
                        <Column field="tipocafe" header="Tipo de café" style="width: 40px"></Column>
                        <Column field="totalrecolectado" header="Veces recolectado" style="width: 40px"></Column>
                        <Column field="totalcafeclasificado" header="Cantidad recolectada" style="width: 60px"></Column>
                    </DataTable>
                </div>
                <div class="card">
                    <!-- SECCIÓN DEL SEXTO REPORTE -->
                    <h4><b>SEXTO REPORTE</b></h4>
                    <hr />
                    <h6><b>Mostrar el promedio del tiempo al mes del secado de los lotes de café.</b></h6>
                    <hr />
                    <Toolbar class="col-3">
                        <template v-slot:start && #body="slotProps">
                            <div class="my-2">
                                <Button label="Exportar Excel" icon="pi pi-sing-out" class="p-button-raised mr-2"
                                    @click="exportarExcelReporteSix()"></Button>
                            </div>
                        </template>
                    </Toolbar>
                    <hr />
                    <DataTable v-bind="value" :value="SixReport" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} registros."
                        responsiveLayout="scroll">
                    <Column field="mes" header="Mes" :sortable="true" style="width: 30px"></Column>
                    <Column field="promediotiemposecado" header="Promedio Tiempo de Secado" style="width: 40px">
                    </Column>
                </DataTable>
            </div>
        </div>
    </div>
</div></template>