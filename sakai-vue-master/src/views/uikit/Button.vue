<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

const productDialog = ref(false);

const openWindow = () => {
    productDialog.value = true;
};
</script>

<script>
import axios from 'axios';
import { ref } from 'vue';

const productDialogActFer = ref(false);
const idsec = ref(false);
const idlava = ref(false);


const productDialogActFermenta = (row) => {
    idsec.value = row.idsecado;
    idlava.value = row.idlavado;
    productDialogActFer.value = true;
};

const dropdownValue = ref(null);

export default {
    data() {
        return {
            cuartos: null,
            secado: null,
            tiposecadoo: null,
            idsecado: idsec,
            idlavado: idlava,
            valSelect: dropdownValue,
            dropdownOptions: [],

        }
    },
    mounted() {
        this.listarTablaCuartos();
        this.opcCuartos();

    },
    methods: {
        async RegistarUnCuarto() {
            try {
                const response = await axios.post('http://localhost:3000/InsertCuartos', { //llamada a la REST API
                    maxkgc: this.kgMaximos // Usar el nombre del terreno ingresado por el usuario
                });
                console.log('Respuesta:', response.data);
                this.$toast.add({ severity: 'success', summary: 'Cuarto ingresado de manera exitosa', detail: '¡Todo bien!', life: 5000 });
            } catch (error) {
                console.error('Error al hacer la solicitud POST:', error);
                this.$toast.add({ severity: 'warn', summary: 'El Cuarto deseado no se ha podido registrar :( )', detail: '¡Probleas internos!', life: 5000 });
            }
            //método con el cual se realiza la recarga de la pagina
            setTimeout(() => {
                location.reload();
            }, 2000); //dos segundos convertidos en milisegundos
        },
        async listarTablaCuartos() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/listarCuartos',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.cuartos = JSON.parse(response.data);
                    console.log(this.cuartos);
                });
        },
        async deleteCuarto(row) {
            try {
                const response = await axios.delete(`http://localhost:3000/deleteCuarto/${row.idcuarto}`);
                this.$toast.add({ severity: 'success', summary: 'Cuarto eliminado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log(response);
            } catch (error) {
                console.error('Error al hacer la solicitud DELETE:', error);
                this.$toast.add({ severity: 'warn', summary: 'El tanque deseado no se ha podido eliminar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            // setTimeout(() => {
            //     location.reload();

            // }, 1000);
        },
        async getAllSecado() {
            axios({
                method: 'POST',
                url: 'http://localhost:3000/cargaLotesSecado',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.secado = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes cargados de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                });
        },
        async listarTablaSecado() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/ListarDatosSecado',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.secado = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes disponibles para Secado', detail: '¡Todo bien!', life: 5000 });
                    console.log(this.secado);
                });
        },
        async opcCuartos() {
            try {
                const response = await axios.get('http://localhost:3000/selectStsCuartos');

                response.data.forEach(element => {
                    this.dropdownOptions.push(element);
                });

            } catch (error) {
                console.error('Error al obtener datos:', error);
            }
        },
        async actRegistroSecado() {
            try {
                const response = await axios.post(`http://localhost:3000/InicioRegistroSecado`, {
                    idsecado: this.idsecado,
                    idlavado: this.idlavado,
                    idcuarto: this.valSelect.code,
                    tiposecado: this.tiposecadoo,
                });
                console.log('dato:', this.idsecado);
                console.log('dato:', this.idlavado);
                console.log('dato:', this.valSelect.code);
                console.log('dato:', this.tiposecadoo);
                this.$toast.add({ severity: 'success', summary: 'Secado iniciado el proceso de Secado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud POST:', error);
                this.$toast.add({ severity: 'warn', summary: 'Está secado no se ha podido cargar:( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async actRegistroSecadoFinish(row) {
            try {
                console.log('entra');
                const response = await axios.post(`http://localhost:3000/finalizarRegistroSecado`, {
                    idsecado: row.idsecado,
                    idlavado: row.idlavado,
                });
                this.$toast.add({ severity: 'success', summary: 'Se ha finalizado el proceso de Secado', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud POST:', error);
                this.$toast.add({ severity: 'warn', summary: 'Problemas es finalizar la Secado:( ', detail: '¡Probleas internos!', life: 1000 });
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
                    <h3>Sección de Cuartos de Secado</h3>
                    <Toast />
                    <Toolbar class="mb-4">
                        <template v-slot:start>
                            <div class="my-2">
                                <Button label="Agregar Un Nuevo Cuarto" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="RegistarUnCuarto()" />
                            </div>
                        </template>
                        <template v-slot:end>
                            <span class="p-input-icon-left mb-2">
                                <i class="pi pi-search" />
                                <InputText placeholder="Codigo de cuarto" style="width: 100%" />
                            </span>
                        </template>
                    </Toolbar>
                    <!--TABLA DE CUARTOS DE SECADO-->
                    <DataTable v-bind="value" :value="cuartos" class="p-datatable-gridlines" :paginator="true" :rows="10"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} Cuartos." responsiveLayout="scroll">
                        <Column field="idcuarto" header="Codigo del Cuarto" :sortable="true" style="width:50px"></Column>
                        <Column field="maxkgc" header="Cantidad de Cafe" style="width:120px"></Column>
                        <Column field="estado" header="Status" style="width:120px"></Column>
                        <Column style="width:120px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"
                                    @click=" "></Button>
                                <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"
                                    @click="deleteCuarto(slotProps.data)"></Button>
                            </template>
                        </Column>
                    </DataTable>
                </div>
                <!--TABLA DE SECADOO-->
                <div class="card">
                    <h3>Sección de Secado</h3>
                    <Toast />
                    <Toolbar class="mb-4">
                        <template v-slot:start>
                            <div class="my-2">
                                <Button label="Cargar Lotes a Secar" icon="pi pi-plus" class="p-button-raised mr-2"
                                    @click="getAllSecado() " />
                                <Button label="Listar lotes a Secar" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="listarTablaSecado()" />
                            </div>
                        </template>
                        <template v-slot:end>
                            <span class="p-input-icon-left mb-2">
                                <i class="pi pi-search" />
                                <InputText placeholder="Codigo de Secado" style="width: 100%" />
                            </span>
                        </template>
                    </Toolbar>
                    <DataTable v-bind="value" :value="secado" class="p-datatable-gridlines" :paginator="true" :rows="10"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes a secar."
                        responsiveLayout="scroll">
                        <Column field="idsecado" header="Codigo de Secado" :sortable="true" style="width:50px"> </Column>
                        <Column field="idlavado" header="Codigo de Lavado" style="width:100px"></Column>
                        <Column field="idcuarto" header="Codigo de Cuarto" style="width:120px"></Column>
                        <Column field="tiposecado" header="Tipo de Secado" style="width:120px"></Column>
                        <Column field="kgsecados" header="Kg. Secados" style="width:120px"></Column>
                        <Column field="fechaini" header="Fecha Inicial" style="width:120px"></Column>
                        <Column field="horaini" header="Hora Inicial" style="width:120px"></Column>
                        <Column field="fechafin" header="Fecha Final" style="width:120px"></Column>
                        <Column field="horafin" header="Hora Final" style="width:120px"></Column>
                        <Column field="statuss" header="Status" style="width:150px"></Column>
                        <Column style="width:180px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-plus" type="button" class="p-button-success p-mr-2 p-mb-1"
                                    @click=" productDialogActFermenta(slotProps.data)"></Button>
                                <Button icon="pi pi-sign-out" type="button" class="p-button-warning p-mb-1"
                                    @click="actRegistroSecadoFinish(slotProps.data) "></Button>
                            </template>
                        </Column>
                    </DataTable>
                </div>
                <Dialog v-model:visible="productDialogActFer" :style="{ width: '500px' }"
                    header="Ingresar datos del lote Secado " modal="true" class="p-fluid">
                    <div class="field">
                        <Dropdown v-model="dropdownValue" :options="dropdownOptions" optionLabel="name" placeholder="Cuartos Disponibles" />
                        <label for="name">Tipo de secado: </label>
                        <InputText id="tiposecado" v-model="tiposecadoo" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2" @click="actRegistroSecado()"></Button>
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>