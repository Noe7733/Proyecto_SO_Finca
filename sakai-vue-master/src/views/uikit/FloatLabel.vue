<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();
</script>

<script>
import axios from 'axios';
import { ref } from 'vue';

const productDialog = ref(false);
const productDialogActFer = ref(false);

//Constantes las cuales sirven para obtener los datos de las ventanas modales en la operación actualización de datos 
const iddespul = ref(false);
const idfer = ref(false);


const openWindow = () => {
    productDialog.value = true;
};
const openWindowActFer = (row) => {
    idfer.value = row.idfermentacion;
    iddespul.value = row.iddespulpado;
    productDialogActFer.value = true;
    console.log(idfer.value);
    console.log(iddespul.value);

    console.log(row);
};

const dropdownValue = ref(null);

export default {
    data() {
        return {
            fermentacion: null,
            tanques: null,
            idtanquee: null,
            tempminn: null,
            tempmaxx: null,
            idfermentacion: idfer,
            iddespulpado: iddespul,
            valSelect: dropdownValue,
            dropdownOptions: [],
        }
    },
    mounted() {
        this.listarTablaT();
        // this.listarTablaFerm();
        this.opcTanques();
    },
    methods: {
        async realizarSolicitudT() {
            try {
                const response = await axios.post('http://localhost:3000/postTanque', { //llamada a la REST API
                    maxkgt: this.kgMaximos // Usar el nombre del terreno ingresado por el usuario
                });
                console.log('Respuesta:', response.data);
                this.$toast.add({ severity: 'success', summary: 'Tanque ingresado de manera exitosa', detail: '¡Todo bien!', life: 5000 });
            } catch (error) {
                console.error('Error al hacer la solicitud POST:', error);
                this.$toast.add({ severity: 'warn', summary: 'El tanque deseado no se ha podido registrar :( )', detail: '¡Probleas internos!', life: 5000 });
            }
            //método con el cual se realiza la recarga de la pagina
            setTimeout(() => {
                location.reload();
            }, 2000); //dos segundos convertidos en milisegundos
        },

        async listarTablaT() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/getTanques',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.tanques = JSON.parse(response.data);
                    console.log(this.tanques);
                });
        },
        async deleteTanque(row) {
            try {
                const response = await axios.delete(`http://localhost:3000/deleteTanque/${row.idtanque}`);
                this.$toast.add({ severity: 'success', summary: 'Tanque eliminado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log(response);
            } catch (error) {
                console.error('Error al hacer la solicitud DELETE:', error);
                this.$toast.add({ severity: 'warn', summary: 'El tanque deseado no se ha podido eliminar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async getAllFernentacion() {
            axios({
                method: 'POST',
                url: 'http://localhost:3000/AllPostFermentacion',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.fermentacion = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes cargados de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                });
        },
        async listarTablaFerm() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/getFermentacion',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.fermentacion = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes disponibles para Fermentar', detail: '¡Todo bien!', life: 5000 });
                    console.log(this.fermentacion);
                });
        },
        async actRegistroFermen() {
            try {
                console.log('entra');
                const response = await axios.post(`http://localhost:3000/updateRegistroFer`, {
                    idfermentacion: this.idfermentacion,
                    iddespulpado: this.iddespulpado,
                    idtanque: this.valSelect.code,
                    tempmin: this.tempminn,
                    tempmax: this.tempmaxx,
                });
                console.log('dato:', this.idfermentacion);
                console.log('dato:', this.iddespulpado);
                console.log('dato:', this.valSelect.code);
                console.log('dato:', this.tempminn);
                console.log('dato:', this.tempmaxx);

                this.$toast.add({ severity: 'success', summary: 'Recolección cargada de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud POST:', error);
                this.$toast.add({ severity: 'warn', summary: 'Está recolección no se ha podido cargar:( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async opcTanques() {
            try {
                const response = await axios.get('http://localhost:3000/selectStsTanques');

                response.data.forEach(element => {
                    this.dropdownOptions.push(element);
                });

            } catch (error) {
                console.error('Error al obtener datos:', error);
            }
        },
        async actRegistroFermenFinish(row) {
            try {
                console.log('entra');
                const response = await axios.post(`http://localhost:3000/finishFermentacion`, {
                    idfermentacion: row.idfermentacion,
                    iddespulpado: row.iddespulpado,
                });
                this.$toast.add({ severity: 'success', summary: 'Se ha finalizado el proceso de Fermentacion', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud POST:', error);
                this.$toast.add({ severity: 'warn', summary: 'Problemas es finalizar la Fermentacion:( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
    }
};

</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <div class="card">
                    <h3>Sección de tanques</h3>
                    <Toast />
                    <Toolbar class="mb-4">
                        <template v-slot:start>
                            <div class="my-2">
                                <Button label="Agregar Tanque" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="realizarSolicitudT()" />
                            </div>
                        </template>
                        <template v-slot:end>
                            <span class="p-input-icon-left mb-2">
                                <i class="pi pi-search" />
                                <InputText placeholder="Codigo de fermentación" style="width: 100%" />
                            </span>
                        </template>
                    </Toolbar>
                    <!--TABLA DE TANQUES-->
                    <DataTable v-bind="value" :value="tanques" class="p-datatable-gridlines" :paginator="true" :rows="10"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} tanque(s)."
                        responsiveLayout="scroll">
                        <Column field="idtanque" header="Codigo del tanque" :sortable="true" style="width:50px"></Column>
                        <Column field="maxkgt" header="Cantidad de café" style="width:120px"></Column>
                        <Column field="statust" header="Status" style="width:170px"></Column>
                        <Column style="width:180px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"
                                    @click="openWindowAct(slotProps.data)"></Button>
                                <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"
                                    @click="deleteTanque(slotProps.data)"></Button>
                            </template>
                        </Column>
                    </DataTable>
                </div>
                <!--TABLA DE FERMETACION-->
                <div class="card">
                    <h3>Sección de Fermentacion</h3>
                    <Toast />
                    <Toolbar class="mb-4">
                        <template v-slot:start>
                            <div class="my-2">
                                <Button label="Cargar Lotes" icon="pi pi-plus" class="p-button-raised mr-2"
                                    @click="getAllFernentacion()" :disabled="botonInhabilitado" />
                                <Button label="Listar lotes a fermentar" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="listarTablaFerm()" />
                            </div>
                        </template>
                        <template v-slot:end>
                            <span class="p-input-icon-left mb-2">
                                <i class="pi pi-search" />
                                <InputText placeholder="Codigo de fermentación" style="width: 100%" />
                            </span>
                        </template>
                    </Toolbar>
                    <DataTable v-bind="value" :value="fermentacion" class="p-datatable-gridlines" :paginator="true"
                        :rows="10"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes a fermentar."
                        responsiveLayout="scroll">
                        <Column field="idfermentacion" header="Codigo de fermentación" :sortable="true" style="width:50px">
                        </Column>
                        <Column field="iddespulpado" header="Codigo de despulpado" style="width:100px"></Column>
                        <Column field="idtanque" header="Codigo de tanque" style="width:120px"></Column>
                        <Column field="tempmin" header="Tem. minima" style="width:120px"></Column>
                        <Column field="tempmax" header="Tem. maxima" style="width:120px"></Column>
                        <Column field="fechafi" header="Fecha Inicial" style="width:120px"></Column>
                        <Column field="timepofi" header="Hora Inicial" style="width:120px"></Column>
                        <Column field="fechaff" header="Fecha Final" style="width:120px"></Column>
                        <Column field="tiempoff" header="Hora Final" style="width:120px"></Column>
                        <Column field="statusf" header="Status" style="width:150px"></Column>
                        <Column style="width:180px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-plus" type="button" class="p-button-success p-mr-2 p-mb-1"
                                    @click="openWindowActFer(slotProps.data)"></Button>
                                <Button icon="pi pi-sign-out" type="button" class="p-button-warning p-mb-1"
                                    @click="actRegistroFermenFinish(slotProps.data)"></Button>
                            </template>
                        </Column>
                    </DataTable>
                </div>
                <!-- VENTANA MODAL PARA LA ACTUALIZACIÓN DE FERMENTACION-->
                <Dialog v-model:visible="productDialogActFer" :style="{ width: '500px' }"
                    header="Ingresar datos del lote Fermentacion " modal="true" class="p-fluid">
                    <div class="field">
                        <Dropdown v-model="dropdownValue" :options="dropdownOptions" optionLabel="name"
                            placeholder="Tanques Disponibles" />

                        <label for="name">Temperatura Minima: </label>
                        <InputText id="tempminn" v-model="tempminn" />
                        <hr>
                        <label for="name">Termperatura Maxima: </label>
                        <InputText id="tempmaxx" v-model="tempmaxx" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="actRegistroFermen()"></Button>
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>
